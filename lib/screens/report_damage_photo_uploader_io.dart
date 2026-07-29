import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> uploadDamagePhoto(SupabaseClient client, String photoPath) async {
  if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
    return photoPath;
  }

  final bytes = await File(photoPath).readAsBytes();
  final fileName = 'damage_reports/${DateTime.now().millisecondsSinceEpoch}${_photoExt(photoPath)}';
  await client.storage.from('heritage-media').uploadBinary(fileName, bytes);
  return client.storage.from('heritage-media').getPublicUrl(fileName);
}

String _photoExt(String path) {
  final i = path.lastIndexOf('.');
  return i >= 0 ? path.substring(i) : '.jpg';
}
