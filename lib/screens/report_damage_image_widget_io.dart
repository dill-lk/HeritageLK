import 'dart:io';

import 'package:flutter/material.dart';

class ReportDamageImageWidget extends StatelessWidget {
  const ReportDamageImageWidget({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
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
