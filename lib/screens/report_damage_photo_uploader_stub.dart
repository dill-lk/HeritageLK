import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _damagePhotoBucket = 'damage-photos';

Future<String> uploadDamagePhoto(SupabaseClient client, XFile photo) async {
  final bytes = await photo.readAsBytes();
  final contentType = photo.mimeType ?? _contentTypeForName(photo.name);
  final extension = _extensionForContentType(contentType);
  final userSegment = client.auth.currentUser?.id ?? 'anonymous';
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final safeName = photo.name
      .replaceAll(RegExp(r'\.[^.]+$'), '')
      .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final storagePath = '$userSegment/$timestamp-${safeName.isEmpty ? 'photo' : safeName}$extension';

  await client.storage.from(_damagePhotoBucket).uploadBinary(
        storagePath,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: false,
        ),
      );

  return client.storage.from(_damagePhotoBucket).getPublicUrl(storagePath);
}

String _contentTypeForName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}

String _extensionForContentType(String contentType) {
  switch (contentType.toLowerCase()) {
    case 'image/png':
      return '.png';
    case 'image/webp':
      return '.webp';
    case 'image/gif':
      return '.gif';
    default:
      return '.jpg';
  }
}
