import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'heritage_colors.dart';

ThemeData buildHeritageTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: HeritageColors.background,
    colorScheme: base.colorScheme.copyWith(
      surface: HeritageColors.background,
      primary: HeritageColors.orange,
      onPrimary: HeritageColors.background,
      onSurface: HeritageColors.cream,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: HeritageColors.cream,
      displayColor: HeritageColors.cream,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
