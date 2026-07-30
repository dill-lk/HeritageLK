import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

const _bucket = 'damage-photos';

Future<String> uploadDamagePhoto(SupabaseClient client, String photoPath) async {
  if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
    return photoPath;
  }

  try {
    final bytes = await _readBytes(photoPath);
    final compressed = await _compressJpeg(bytes);
    final fileName = 'damage-reports/${DateTime.now().millisecondsSinceEpoch}-${_randomId()}.jpg';

    await client.storage.from(_bucket).uploadBinary(
          fileName,
          compressed,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return client.storage.from(_bucket).getPublicUrl(fileName);
  } catch (e) {
    throw Exception('Failed to upload photo to Supabase Storage: $e');
  }
}

Future<Uint8List> _readBytes(String photoPath) async {
  if (photoPath.startsWith('data:image')) {
    final base64Str = photoPath.split(',').last;
    return base64Decode(base64Str);
  }

  if (photoPath.startsWith('blob:')) {
    final response = await html.window.fetch(photoPath);
    final blob = await response.blob();
    return _readBlob(blob);
  }

  final request = await html.HttpRequest.request(
    photoPath,
    responseType: 'arraybuffer',
  );
  return Uint8List.view(request.response as ByteBuffer);
}

Future<Uint8List> _readBlob(html.Blob blob) async {
  final reader = html.FileReader();
  final completer = Completer<Uint8List>();
  reader.onLoad.listen((_) {
    final result = reader.result;
    if (result is ByteBuffer) {
      completer.complete(Uint8List.view(result));
    } else {
      completer.completeError('Unexpected FileReader result');
    }
  });
  reader.onError.listen((_) => completer.completeError('Failed to read blob'));
  reader.readAsArrayBuffer(blob);
  return completer.future;
}

Future<Uint8List> _compressJpeg(Uint8List bytes) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final img = html.ImageElement();
  final completer = Completer<Uint8List>();

  img.onLoad.listen((_) {
    try {
      final maxWidth = 800;
      final width = img.width!;
      final height = img.height!;
      var newWidth = width;
      var newHeight = height;

      if (width > maxWidth) {
        final ratio = maxWidth / width;
        newWidth = maxWidth;
        newHeight = (height * ratio).round();
      }

      final canvas = html.CanvasElement(width: newWidth, height: newHeight);
      final ctx = canvas.context2D;
      ctx.drawImageScaled(img, 0, 0, newWidth, newHeight);

      final dataUrl = canvas.toDataURL('image/jpeg', 0.75);
      final base64Str = dataUrl.split(',').last;
      final compressed = base64Decode(base64Str);

      html.Url.revokeObjectUrl(url);
      completer.complete(compressed);
    } catch (e) {
      html.Url.revokeObjectUrl(url);
      completer.complete(bytes);
    }
  });

  img.onError.listen((_) {
    html.Url.revokeObjectUrl(url);
    completer.complete(bytes);
  });

  img.src = url;
  return completer.future;
}

String _randomId() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rng = Random();
  return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
}
