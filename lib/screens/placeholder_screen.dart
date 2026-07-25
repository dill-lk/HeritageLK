import 'package:flutter/material.dart';

import '../theme/heritage_colors.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeritageColors.background,
        foregroundColor: HeritageColors.cream,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(color: HeritageColors.cream),
        ),
      ),
    );
  }
}
