import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Converts a local image file to a compressed base64 data URL and returns it.
/// The result is stored directly in the `photo_url` column of `damage_reports`.
/// No Supabase Storage bucket is required.
Future<String> uploadDamagePhoto(SupabaseClient client, String photoPath) async {
  // Already a URL or data URL — return as-is
  if (photoPath.startsWith('http://') ||
      photoPath.startsWith('https://') ||
      photoPath.startsWith('data:image')) {
    return photoPath;
  }

  try {
    final file = File(photoPath);
    if (!await file.exists()) return photoPath;

    // Compress to JPEG, max 800px wide, quality 75 — keeps base64 string small
    Uint8List? compressed;
    try {
      compressed = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 800,
        minHeight: 600,
        quality: 75,
        format: CompressFormat.jpeg,
      );
    } catch (_) {
      // Compression unavailable (e.g. web stub) — read raw bytes
    }

    final bytes = compressed ?? await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64Str';

    return dataUrl;
  } catch (e) {
    // Last resort — return the raw path (admin will show broken image)
    return photoPath;
  }
}
