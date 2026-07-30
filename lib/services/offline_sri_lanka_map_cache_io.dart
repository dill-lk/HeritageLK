import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Snapshot emitted while tiles are being downloaded.
class OfflineTileProgress {
  final int downloaded;
  final int total;
  final bool isComplete;
  final bool isFailed;

  const OfflineTileProgress({
    required this.downloaded,
    required this.total,
    this.isComplete = false,
    this.isFailed = false,
  });

  double get fraction => total == 0 ? 0 : (downloaded / total).clamp(0.0, 1.0);
}

class SriLankaOfflineMapCache {
  SriLankaOfflineMapCache._();

  static final SriLankaOfflineMapCache instance = SriLankaOfflineMapCache._();

  // v3 marker = wider bounding box — forces re-download if user had v2 tiles.
  static const _markerFileName = 'sri_lanka_tiles_ready_v3.marker';
  static const _minZoom = 6;

  // Z6–Z11: gives good interactive coverage without exploding storage.
  // The wider bounding box below compensates for not having Z12/Z13 edges.
  static const _maxZoom = 11;

  // Expanded bounding box: SL proper + ~2° padding on every side.
  // Prevents blank tiles when map is panned to coasts / borders.
  static const double _north = 11.5; // was 10.05
  static const double _south = 4.5;  // was  5.82
  static const double _west  = 77.8; // was 79.45
  static const double _east  = 83.8; // was 82.15

  // Keep 4 OSM requests in-flight at a time (OSM ToS: reasonable use).
  static const _concurrency = 4;

  Future<Directory?>? _rootDirectoryFuture;
  bool _warmupStarted = false;

  // Broadcast so explore + heatmap screens can both subscribe.
  final _progressController = StreamController<OfflineTileProgress>.broadcast();

  /// Live progress updates during tile download.
  Stream<OfflineTileProgress> get progressStream => _progressController.stream;

  Future<Directory?> ensureRootDirectory() {
    if (kIsWeb) return Future.value(null);
    return _rootDirectoryFuture ??= _createRootDirectory();
  }

  Future<String?> ensureLocalTemplate() async {
    final directory = await ensureRootDirectory();
    if (directory == null) return null;
    return p.join(directory.path, 'offline_sri_lanka', '{z}', '{x}', '{y}.png');
  }

  /// Returns true when all tiles are on disk and ready to serve offline.
  Future<bool> isTilesReady() async {
    if (kIsWeb) return false;
    final directory = await ensureRootDirectory();
    if (directory == null) return false;
    final marker = File(p.join(directory.path, _markerFileName));
    return marker.exists();
  }

  /// Total tile count across the expanded bounding box and all zoom levels.
  int countTotalTiles() {
    var total = 0;
    for (var z = _minZoom; z <= _maxZoom; z++) {
      final xr = _tileRangeX(_west, _east, z);
      final yr = _tileRangeY(_north, _south, z);
      total += (xr.end - xr.start + 1) * (yr.end - yr.start + 1);
    }
    return total;
  }

  /// Downloads all tiles for the expanded Sri Lanka bounding box.
  /// Emits [OfflineTileProgress] on [progressStream] for every tile that
  /// completes (including already-cached ones) so the UI always sees smooth
  /// progress.  Safe to call multiple times — skips files already on disk.
  Future<void> warmSriLankaTiles() async {
    if (kIsWeb || _warmupStarted) return;
    _warmupStarted = true;

    final directory = await ensureRootDirectory();
    if (directory == null) return;

    final marker = File(p.join(directory.path, _markerFileName));
    if (await marker.exists()) {
      final total = countTotalTiles();
      if (!_progressController.isClosed) {
        _progressController.add(
            OfflineTileProgress(downloaded: total, total: total, isComplete: true));
      }
      return;
    }

    final total = countTotalTiles();
    var downloaded = 0;

    // Emit 0/total immediately so the banner appears before any tile finishes.
    if (!_progressController.isClosed) {
      _progressController.add(OfflineTileProgress(downloaded: 0, total: total));
    }

    // Build ordered tile list (low zoom first = fastest first paint).
    final allTiles = <(int, int, int)>[];
    for (var z = _minZoom; z <= _maxZoom; z++) {
      final xRange = _tileRangeX(_west, _east, z);
      final yRange = _tileRangeY(_north, _south, z);
      for (var x = xRange.start; x <= xRange.end; x++) {
        for (var y = yRange.start; y <= yRange.end; y++) {
          allTiles.add((z, x, y));
        }
      }
    }

    final client = http.Client();
    try {
      // Sliding-window concurrency: _concurrency futures always in-flight.
      // Progress fires after EVERY single tile (not per batch) → smooth bar.
      final iter = allTiles.iterator;

      // Wrap each download so we can identify which future finished.
      Future<({Future<dynamic> self, bool result})> wrap(int z, int x, int y) {
        late Future<({Future<dynamic> self, bool result})> f;
        f = _downloadTile(client, directory, z, x, y)
            .then((r) => (self: f, result: r));
        return f;
      }

      final active = <Future<({Future<dynamic> self, bool result})>>[];

      void enqueue() {
        while (active.length < _concurrency && iter.moveNext()) {
          final (z, x, y) = iter.current;
          active.add(wrap(z, x, y));
        }
      }

      enqueue();

      while (active.isNotEmpty) {
        final finished = await Future.any(active);
        active.removeWhere((f) => identical(f, finished.self as dynamic));
        downloaded++;

        if (!_progressController.isClosed) {
          _progressController.add(
              OfflineTileProgress(downloaded: downloaded, total: total));
        }

        enqueue();
      }

      await marker.writeAsString('ready');
      if (!_progressController.isClosed) {
        _progressController.add(OfflineTileProgress(
            downloaded: total, total: total, isComplete: true));
      }
    } catch (e) {
      debugPrint('[OfflineMap] Download failed: $e');
      if (!_progressController.isClosed) {
        _progressController.add(OfflineTileProgress(
            downloaded: downloaded, total: total, isFailed: true));
      }
      _warmupStarted = false; // allow retry on next app launch
    } finally {
      client.close();
    }
  }

  Future<Directory> _createRootDirectory() async {
    final supportDir = await getApplicationSupportDirectory();
    final root = Directory(p.join(supportDir.path, 'offline_maps'));
    if (!await root.exists()) await root.create(recursive: true);
    final tiles = Directory(p.join(root.path, 'offline_sri_lanka'));
    if (!await tiles.exists()) await tiles.create(recursive: true);
    return root;
  }

  /// Downloads a single tile from OSM.
  /// Returns true when the tile is on disk (freshly downloaded or pre-cached).
  Future<bool> _downloadTile(
      http.Client client, Directory root, int z, int x, int y) async {
    final filePath =
        p.join(root.path, 'offline_sri_lanka', '$z', '$x', '$y.png');
    final file = File(filePath);
    if (await file.exists()) return true; // already cached — count as done

    await file.parent.create(recursive: true);
    final url = Uri.parse('https://tile.openstreetmap.org/$z/$x/$y.png');

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await client
            .get(url, headers: {
              'User-Agent':
                  'HeritageLK/1.0 (flutter_map; +https://github.com/fleaflet/flutter_map)',
            })
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          await file.writeAsBytes(response.bodyBytes, flush: true);
          return true;
        }
      } catch (_) {
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }
    return false;
  }

  ({int start, int end}) _tileRangeX(double west, double east, int zoom) {
    final n = pow(2, zoom).toInt();
    final start =
        (((west + 180.0) / 360.0) * n).floor().clamp(0, n - 1).toInt();
    final end =
        (((east + 180.0) / 360.0) * n).floor().clamp(0, n - 1).toInt();
    return (start: min(start, end), end: max(start, end));
  }

  ({int start, int end}) _tileRangeY(double north, double south, int zoom) {
    final n = pow(2, zoom).toInt();
    final start = _latToTileY(north, zoom).clamp(0, n - 1).toInt();
    final end = _latToTileY(south, zoom).clamp(0, n - 1).toInt();
    return (start: min(start, end), end: max(start, end));
  }

  int _latToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180.0;
    final n = pow(2, zoom).toDouble();
    return ((1 - log(tan(latRad) + (1 / cos(latRad))) / pi) / 2 * n).floor();
  }
}
