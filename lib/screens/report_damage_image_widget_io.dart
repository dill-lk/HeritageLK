import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReportDamageImageWidget extends StatelessWidget {
  const ReportDamageImageWidget({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    // base64 data URL — decode and render as memory image
    if (path.startsWith('data:image')) {
      try {
        final commaIdx = path.indexOf(',');
        if (commaIdx != -1) {
          final Uint8List bytes = base64Decode(path.substring(commaIdx + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _broken(),
          );
        }
      } catch (_) {}
      return _broken();
    }

    // Remote HTTP/HTTPS URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _broken(),
      );
    }

    // Local file path
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _broken(),
    );
  }

  Widget _broken() => Container(
        color: Colors.white10,
        child: const Icon(Icons.broken_image_outlined, color: Colors.white38),
      );
}

