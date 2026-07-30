import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> uploadDamagePhoto(SupabaseClient client, String photoPath) async {
  if (photoPath.startsWith('http://') || photoPath.startsWith('https://') || photoPath.startsWith('data:image')) {
    return photoPath;
  }

  try {
    final bytes = await File(photoPath).readAsBytes();
    final ext = _photoExt(photoPath);
    final fileName = 'damage_reports/${DateTime.now().millisecondsSinceEpoch}$ext';

    try {
      await client.storage.from('heritage-media').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      return client.storage.from('heritage-media').getPublicUrl(fileName);
    } catch (_) {
      // Storage upload failed — encode to base64 data URL so photo_url column receives a valid viewable image
      final mime = ext.contains('png') ? 'image/png' : 'image/jpeg';
      final base64Str = base64Encode(bytes);
      return 'data:$mime;base64,$base64Str';
    }
  } catch (e) {
    return photoPath;
  }
}

String _photoExt(String path) {
  final i = path.lastIndexOf('.');
  return i >= 0 ? path.substring(i) : '.jpg';
}
