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

  static const _markerFileName = 'sri_lanka_tiles_ready_v2.marker';
  static const _minZoom = 6;
  // Z6–Z13 covers Sri Lanka at interactive zoom depth.
  // Approx tile counts per level for SL bounding box:
  //   Z6 ~15, Z7 ~60, Z8 ~240, Z9 ~960, Z10 ~3.8k,
  //   Z11 ~15k, Z12 ~60k, Z13 ~240k   → total ≈ 320k tiles ≈ ~95 MB
  static const _maxZoom = 13;

  static const double _north = 10.05;
  static const double _south = 5.82;
  static const double _west  = 79.45;
  static const double _east  = 82.15;

  Future<Directory?>? _rootDirectoryFuture;
  bool _warmupStarted = false;

  // Stream controller so the UI can subscribe to download progress.
  final _progressController =
      StreamController<OfflineTileProgress>.broadcast();

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

  /// Returns true if tiles are fully downloaded and ready to serve offline.
  Future<bool> isTilesReady() async {
    if (kIsWeb) return false;
    final directory = await ensureRootDirectory();
    if (directory == null) return false;
    final marker = File(p.join(directory.path, _markerFileName));
    return marker.exists();
  }

  /// Pre-computes total tile count for SL bounding box across all zoom levels.
  int countTotalTiles() {
    var total = 0;
    for (var z = _minZoom; z <= _maxZoom; z++) {
      final xr = _tileRangeX(_west, _east, z);
      final yr = _tileRangeY(_north, _south, z);
      total += (xr.end - xr.start + 1) * (yr.end - yr.start + 1);
    }
    return total;
  }

  /// Downloads all Sri Lanka tiles.
  /// Emits [OfflineTileProgress] events on [progressStream].
  /// Safe to call multiple times — skips tiles already on disk.
  Future<void> warmSriLankaTiles() async {
    if (kIsWeb || _warmupStarted) return;
    _warmupStarted = true;

    final directory = await ensureRootDirectory();
    if (directory == null) return;

    final marker = File(p.join(directory.path, _markerFileName));
    if (await marker.exists()) {
      // Already complete — report immediately.
      final total = countTotalTiles();
      _progressController.add(OfflineTileProgress(
          downloaded: total, total: total, isComplete: true));
      return;
    }

    final total = countTotalTiles();
    var downloaded = 0;

    _progressController.add(OfflineTileProgress(downloaded: 0, total: total));

    final client = http.Client();
    try {
      for (var z = _minZoom; z <= _maxZoom; z++) {
        final xRange = _tileRangeX(_west, _east, z);
        final yRange = _tileRangeY(_north, _south, z);

        // Smaller batch at high zoom to avoid exhausting memory/connections.
        final batchSize = z <= 9 ? 64 : (z <= 11 ? 32 : 16);
        final batch = <Future<bool>>[];

        for (var x = xRange.start; x <= xRange.end; x++) {
          for (var y = yRange.start; y <= yRange.end; y++) {
            batch.add(_downloadTile(client, directory, z, x, y));
            if (batch.length >= batchSize) {
              final results = await Future.wait(batch);
              downloaded += results.where((ok) => ok).length +
                  results.where((ok) => !ok).length; // count skipped too
              batch.clear();
              if (!_progressController.isClosed) {
                _progressController.add(
                    OfflineTileProgress(downloaded: downloaded, total: total));
              }
            }
          }
        }

        if (batch.isNotEmpty) {
          final results = await Future.wait(batch);
          downloaded += results.length;
          if (!_progressController.isClosed) {
            _progressController.add(
                OfflineTileProgress(downloaded: downloaded, total: total));
          }
        }
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
      // Reset so the next app launch can retry.
      _warmupStarted = false;
    } finally {
      client.close();
    }
  }

  Future<Directory> _createRootDirectory() async {
    final supportDir = await getApplicationSupportDirectory();
    final root = Directory(p.join(supportDir.path, 'offline_maps'));
    if (!await root.exists()) await root.create(recursive: true);
    // Also ensure the tile subdirectory exists.
    final tiles =
        Directory(p.join(root.path, 'offline_sri_lanka'));
    if (!await tiles.exists()) await tiles.create(recursive: true);
    return root;
  }

  static const List<String> _subdomains = ['a', 'b', 'c'];

  /// Downloads a single tile.
  /// Returns true when the tile is available on disk (either freshly
  /// downloaded or already existed).  Returns false only on unrecoverable error.
  Future<bool> _downloadTile(
      http.Client client, Directory root, int z, int x, int y) async {
    final filePath =
        p.join(root.path, 'offline_sri_lanka', '$z', '$x', '$y.png');
    final file = File(filePath);
    if (await file.exists()) return true; // already cached

    await file.parent.create(recursive: true);
    final sub = _subdomains[(x + y) % _subdomains.length];
    final url =
        Uri.parse('https://$sub.basemaps.cartocdn.com/dark_all/$z/$x/$y.png');

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await client
            .get(url,
                headers: {'User-Agent': 'HeritageLK/1.0 (Flutter; Android)'})
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          await file.writeAsBytes(response.bodyBytes, flush: true);
          return true;
        }
      } catch (_) {
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
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
    final value =
        (1 - log(tan(latRad) + (1 / cos(latRad))) / pi) / 2 * n;
    return value.floor();
  }
}
