import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/heritage_colors.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: HeritageColors.brown.withValues(alpha:0.10),
                  border: Border.all(
                    color: HeritageColors.brown.withValues(alpha:0.30),
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HeritageLK',
                      style: GoogleFonts.plusJakartaSans(
                        color: HeritageColors.cream,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Explore and preserve Sri Lanka's heritage.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: HeritageColors.brown,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _ActionButton(
                      label: 'Sign In',
                      onPressed: () => Navigator.of(context).pushNamed('/login'),
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      label: 'Sign Up',
                      outlined: true,
                      onPressed: () => Navigator.of(context).pushNamed('/signup'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: HeritageColors.orange,
                side: BorderSide(color: HeritageColors.orange.withValues(alpha:0.40)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(label),
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: HeritageColors.orange,
                foregroundColor: HeritageColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(label),
            ),
    );
  }
}

