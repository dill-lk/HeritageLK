abstract class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Embedded default Gemini API key for instant out-of-the-box user experience
  static const String _embeddedDefaultKey = 'AIzaSyBI6mNhWme4EsYoUgYhnNioWkzFw1Ew0VI';

  static String _userGeminiApiKey = '';

  static String get userGeminiApiKey => _userGeminiApiKey;

  static set userGeminiApiKey(String key) {
    _userGeminiApiKey = key.trim();
  }

  static String get effectiveGeminiApiKey {
    if (_userGeminiApiKey.isNotEmpty) return _userGeminiApiKey;
    if (geminiApiKey.isNotEmpty) return geminiApiKey;
    return _embeddedDefaultKey;
  }

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
