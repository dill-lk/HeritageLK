import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

const _damagePhotoBucket = 'damage-photos';

/// Uploads a picked damage-report image to Supabase Storage and returns its
/// public URL for storage in `damage_reports.photos` and `photo_url`.
Future<String> uploadDamagePhoto(SupabaseClient client, XFile photo) async {
  final bytes = await _compressedBytes(photo);
  final storagePath = _storagePath(client, photo);

  await client.storage.from(_damagePhotoBucket).uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: false,
        ),
      );

  return client.storage.from(_damagePhotoBucket).getPublicUrl(storagePath);
}

Future<Uint8List> _compressedBytes(XFile photo) async {
  try {
    final compressed = await FlutterImageCompress.compressWithFile(
      photo.path,
      minWidth: 1200,
      minHeight: 900,
      quality: 82,
      format: CompressFormat.jpeg,
    );
    if (compressed != null && compressed.isNotEmpty) return compressed;
  } catch (_) {
    // Some platform pickers expose paths that the native compressor cannot read.
  }

  return photo.readAsBytes();
}

String _storagePath(SupabaseClient client, XFile photo) {
  final userSegment = client.auth.currentUser?.id ?? 'anonymous';
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final baseName = p.basenameWithoutExtension(photo.name.isNotEmpty ? photo.name : photo.path);
  final safeName = baseName.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  final suffix = safeName.isEmpty ? 'photo' : safeName;

  return '$userSegment/$timestamp-$suffix.jpg';
}
