class SriLankaOfflineMapCache {
  SriLankaOfflineMapCache._();

  static final SriLankaOfflineMapCache instance = SriLankaOfflineMapCache._();

  Future<String?> ensureLocalTemplate() async => null;

  /// Web stub — always returns false since there is no local tile cache on web.
  Future<bool> isTilesReady() async => false;

  Future<void> warmSriLankaTiles() async {}
}
