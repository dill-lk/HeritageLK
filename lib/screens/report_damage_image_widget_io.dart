import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReportDamageImageWidget extends StatelessWidget {
  const ReportDamageImageWidget({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(imageUrl: path, fit: BoxFit.cover);
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: Colors.white10,
          child: const Icon(Icons.image, color: Colors.white54),
        );
      },
    );
  }
}
