import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _bucket = 'heritage-media';

/// Uploads a local image file to Supabase Storage and returns the public URL.
/// If the storage upload fails for any reason (bucket missing, RLS, network),
/// falls back to a compressed base64 data URL so the report is never lost.
Future<String> uploadDamagePhoto(SupabaseClient client, String photoPath) async {
  // Already a remote URL or data URL — return as-is
  if (photoPath.startsWith('http://') ||
      photoPath.startsWith('https://') ||
      photoPath.startsWith('data:image')) {
    return photoPath;
  }

  try {
    final file = File(photoPath);
    if (!await file.exists()) return photoPath;

    // Compress to JPEG, max 800px wide, quality 75
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
      // Compression unavailable — use raw bytes
    }
    final bytes = compressed ?? await file.readAsBytes();

    // --- Try Supabase Storage first ---
    try {
      final fileName =
          'damage-reports/${DateTime.now().millisecondsSinceEpoch}-${_randomId()}.jpg';
      await client.storage.from(_bucket).uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      return client.storage.from(_bucket).getPublicUrl(fileName);
    } catch (_) {
      // Storage failed (bucket missing, RLS, network) — fall back to base64
    }

    // --- Fallback: encode as base64 data URL ---
    final base64Str = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64Str';
  } catch (e) {
    // Last resort — return the raw path
    return photoPath;
  }
}

String _randomId() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rng = Random();
  return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
}
