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
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is ByteBuffer) {
        completer.complete(Uint8List.view(result));
      } else if (result is html.Blob) {
        final reader2 = html.FileReader();
        final completer2 = Completer<Uint8List>();
        reader2.onLoadEnd.listen((_) {
          final r2 = reader2.result;
          if (r2 is ByteBuffer) {
            completer2.complete(Uint8List.view(r2));
          } else {
            completer2.completeError('Unexpected FileReader result type');
          }
        });
        reader2.readAsArrayBuffer(result);
        return completer2.future;
      } else {
        completer.completeError('Unexpected FileReader result type');
      }
    });
    reader.readAsArrayBuffer(blob);
    return completer.future;
  }

  final request = await html.HttpRequest.request(
    photoPath,
    responseType: 'arraybuffer',
  );
  return Uint8List.view(request.response as ByteBuffer);
}

Future<Uint8List> _compressJpeg(Uint8List bytes) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final img = html.ImageElement();
  final completer = Completer<Uint8List>();

  img.onLoad.listen((_) {
    final canvas = html.Canvas(width: img.width!, height: img.height!);
    final ctx = canvas.context2D;
    ctx.drawImageScaled(img, 0, 0, canvas.width!, canvas.height!);

    final maxWidth = 800;
    if (canvas.width > maxWidth) {
      final ratio = maxWidth / canvas.width;
      final newWidth = maxWidth;
      final newHeight = (canvas.height * ratio).round();
      final resized = html.Canvas(width: newWidth, height: newHeight);
      resized.context2D.drawImageScaled(canvas, 0, 0, newWidth, newHeight);
      resized.toBlob('image/jpeg', 0.75).then((blob) {
        final reader = html.FileReader();
        final c = Completer<Uint8List>();
        reader.onLoadEnd.listen((_) {
          final result = reader.result;
          if (result is ByteBuffer) {
            c.complete(Uint8List.view(result));
          } else {
            c.complete(bytes);
          }
        });
        reader.readAsArrayBuffer(blob);
        completer.complete(c.future);
      }).catchError((_) => completer.complete(bytes));
    } else {
      canvas.toBlob('image/jpeg', 0.75).then((blob) {
        final reader = html.FileReader();
        final c = Completer<Uint8List>();
        reader.onLoadEnd.listen((_) {
          final result = reader.result;
          if (result is ByteBuffer) {
            c.complete(Uint8List.view(result));
          } else {
            c.complete(bytes);
          }
        });
        reader.readAsArrayBuffer(blob);
        completer.complete(c.future);
      }).catchError((_) => completer.complete(bytes));
    }
    html.Url.revokeObjectUrl(url);
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
