abstract class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // SHA256 (password: 2011812) encrypted Gemini API key payload
  static const String _encryptedEmbeddedKey =
      'c9cfe5a7d5af539da818bb5ad309c337db5d5c443476f1d27b33212fab3083aadbabfcd6d3d035b9f662b076b410cc3ad2285f462f';

  static String _userGeminiApiKey = '';

  static String get userGeminiApiKey => _userGeminiApiKey;

  static set userGeminiApiKey(String key) {
    _userGeminiApiKey = key.trim();
  }

  static String get _decryptedDefaultKey {
    try {
      const passHashHex = '889ecbe6b79701d39e52e21e8245a54d996a38736e3ac5b54c45664ed174f0f9';
      final passHash = <int>[];
      for (var i = 0; i < passHashHex.length; i += 2) {
        passHash.add(int.parse(passHashHex.substring(i, i + 2), radix: 16));
      }
      final cipherBytes = <int>[];
      for (var i = 0; i < _encryptedEmbeddedKey.length; i += 2) {
        cipherBytes.add(int.parse(_encryptedEmbeddedKey.substring(i, i + 2), radix: 16));
      }
      final decrypted = <int>[];
      for (var i = 0; i < cipherBytes.length; i++) {
        decrypted.add(cipherBytes[i] ^ passHash[i % passHash.length]);
      }
      return String.fromCharCodes(decrypted);
    } catch (_) {
      return '';
    }
  }

  static String get effectiveGeminiApiKey {
    if (_userGeminiApiKey.isNotEmpty) return _userGeminiApiKey;
    if (geminiApiKey.isNotEmpty) return geminiApiKey;
    return _decryptedDefaultKey;
  }

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
