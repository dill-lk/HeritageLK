import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heritage_lk/main.dart';
import 'package:heritage_lk/theme/heritage_colors.dart';

void main() {
  group('HeritageLK Theme', () {
    test('background color is #100E0A', () {
      expect(HeritageColors.background, const Color(0xFF100E0A));
    });

    test('orange color is #F4A261', () {
      expect(HeritageColors.orange, const Color(0xFFF4A261));
    });

    test('brown color is #8B5E3C', () {
      expect(HeritageColors.brown, const Color(0xFF8B5E3C));
    });

    test('cream color is #FEFAE0', () {
      expect(HeritageColors.cream, const Color(0xFFFEFAE0));
    });
  });

  group('Main App', () {
    testWidgets('renders MaterialApp without crashing', (tester) async {
      await tester.pumpWidget(const HeritageLkApp());
      expect(find.byType(HeritageLkApp), findsOneWidget);
    });
  });
}
