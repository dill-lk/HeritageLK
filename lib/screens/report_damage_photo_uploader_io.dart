import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _bucket = 'damage-photos';

/// Uploads a local image file to Supabase Storage and returns the public URL.
Future<String> uploadDamagePhoto(SupabaseClient client, String photoPath) async {
  // Already a public URL — return as-is
  if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
    return photoPath;
  }

  try {
    Uint8List bytes;

    if (photoPath.startsWith('data:image')) {
      bytes = base64Decode(photoPath.split(',').last);
    } else {
      final file = File(photoPath);
      if (!await file.exists()) throw Exception('Photo file not found: $photoPath');

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
        // Compression unavailable — read raw bytes
      }
      bytes = compressed ?? await file.readAsBytes();
    }
    final fileName = 'damage-reports/${DateTime.now().millisecondsSinceEpoch}-${_randomId()}.jpg';

    await client.storage.from(_bucket).uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return client.storage.from(_bucket).getPublicUrl(fileName);
  } catch (e) {
    throw Exception('Failed to upload photo to Supabase Storage: $e');
  }
}

String _randomId() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rng = Random();
  return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
}
