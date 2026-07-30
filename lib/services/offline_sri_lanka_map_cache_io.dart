import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SriLankaOfflineMapCache {
  SriLankaOfflineMapCache._();

  static final SriLankaOfflineMapCache instance = SriLankaOfflineMapCache._();

  static const _markerFileName = 'sri_lanka_tiles_ready_v1.marker';
  static const _minZoom = 6;
  static const _maxZoom = 10;

  static const double _north = 10.05;
  static const double _south = 5.82;
  static const double _west = 79.45;
  static const double _east = 82.15;

  Future<Directory?>? _rootDirectoryFuture;
  bool _warmupStarted = false;

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
  /// Fast path on subsequent launches — no network call needed.
  Future<bool> isTilesReady() async {
    if (kIsWeb) return false;
    final directory = await ensureRootDirectory();
    if (directory == null) return false;
    final marker = File(p.join(directory.path, _markerFileName));
    return marker.exists();
  }

  Future<void> warmSriLankaTiles() async {
    if (kIsWeb || _warmupStarted) return;
    _warmupStarted = true;

    final directory = await ensureRootDirectory();
    if (directory == null) return;

    final marker = File(p.join(directory.path, _markerFileName));
    if (await marker.exists()) return;

    final client = http.Client();
    try {
      for (var z = _minZoom; z <= _maxZoom; z++) {
        final xRange = _tileRangeX(_west, _east, z);
        final yRange = _tileRangeY(_north, _south, z);
        final downloads = <Future<void>>[];

        for (var x = xRange.start; x <= xRange.end; x++) {
          for (var y = yRange.start; y <= yRange.end; y++) {
            downloads.add(_downloadTile(client, directory, z, x, y));
            if (downloads.length >= 48) {
              await Future.wait(downloads);
              downloads.clear();
            }
          }
        }

        if (downloads.isNotEmpty) {
          await Future.wait(downloads);
        }
      }

      await marker.writeAsString('ready');
    } catch (_) {
      // Keep the app functional even if the background cache fails.
    } finally {
      client.close();
    }
  }

  Future<Directory> _createRootDirectory() async {
    final supportDir = await getApplicationSupportDirectory();
    final root = Directory(p.join(supportDir.path, 'offline_maps'));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    final sriLanka = Directory(p.join(root.path, 'sri_lanka'));
    if (!await sriLanka.exists()) {
      await sriLanka.create(recursive: true);
    }
    return root;
  }

  static const List<String> _subdomains = ['a', 'b', 'c'];

  Future<void> _downloadTile(http.Client client, Directory root, int z, int x, int y) async {
    final filePath = p.join(root.path, 'sri_lanka', '$z', '$x', '$y.png');
    final file = File(filePath);
    if (await file.exists()) return;

    await file.parent.create(recursive: true);
    final sub = _subdomains[(x + y) % _subdomains.length];
    final url = Uri.parse('https://$sub.basemaps.cartocdn.com/dark_all/$z/$x/$y.png');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
      }
    } catch (_) {}
  }

  ({int start, int end}) _tileRangeX(double west, double east, int zoom) {
    final n = pow(2, zoom).toInt();
    final start = (((west + 180.0) / 360.0) * n).floor().clamp(0, n - 1).toInt();
    final end = (((east + 180.0) / 360.0) * n).floor().clamp(0, n - 1).toInt();
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
    final value = (1 - log(tan(latRad) + (1 / cos(latRad))) / pi) / 2 * n;
    return value.floor();
  }
}

