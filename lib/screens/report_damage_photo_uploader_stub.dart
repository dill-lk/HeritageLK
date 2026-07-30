import 'package:supabase_flutter/supabase_flutter.dart';

/// Fallback stub — should not be used when io or web implementations are available.
Future<String> uploadDamagePhoto(SupabaseClient client, String photoPath) async {
  if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
    return photoPath;
  }
  throw UnsupportedError('Photo upload is not supported on this platform');
}
