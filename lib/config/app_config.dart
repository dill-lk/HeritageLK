abstract class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // ── Embedded Gemini API keys (users never see these) ──────────────────────
  // Primary embedded key — replace this with a fresh key if the current one
  // hits quota limits. Get a free key at: https://aistudio.google.com/apikey
  static const String _primaryKey = 'AIzaSyBI6mNhWme4EsYoUgYhnNioWkzFw1Ew0VI';

  // Secondary embedded key as backup (set to empty string if not needed)
  static const String _secondaryKey = '';

  static String _userGeminiApiKey = '';

  static String get userGeminiApiKey => _userGeminiApiKey;

  static set userGeminiApiKey(String key) {
    _userGeminiApiKey = key.trim();
  }

  /// Returns the best available Gemini API key.
  /// Priority: user-provided > env var > primary embedded > secondary embedded
  static String get effectiveGeminiApiKey {
    if (_userGeminiApiKey.isNotEmpty) return _userGeminiApiKey;
    if (geminiApiKey.isNotEmpty) return geminiApiKey;
    if (_primaryKey.isNotEmpty) return _primaryKey;
    if (_secondaryKey.isNotEmpty) return _secondaryKey;
    return '';
  }

  /// Whether a Gemini key is available at all
  static bool get hasGeminiKey => effectiveGeminiApiKey.isNotEmpty;

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
