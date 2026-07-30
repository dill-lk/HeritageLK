import 'dart:async';

/// Progress snapshot — web stub always returns empty/complete.
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

/// Web stub — no offline tile support on web platform.
class SriLankaOfflineMapCache {
  SriLankaOfflineMapCache._();

  static final SriLankaOfflineMapCache instance = SriLankaOfflineMapCache._();

  Stream<OfflineTileProgress> get progressStream => const Stream.empty();

  Future<String?> ensureLocalTemplate() async => null;

  Future<bool> isTilesReady() async => false;

  Future<void> warmSriLankaTiles() async {}

  int countTotalTiles() => 0;
}
