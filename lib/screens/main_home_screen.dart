import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';

/// Auth gate — shown at app launch (route '/').
/// Listens to Supabase auth state and routes accordingly:
///   • Session exists  → /home  (user stays logged in across app restarts)
///   • No session      → landing page with Sign In / Sign Up
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  /// true while we haven't yet determined the auth state
  bool _loading = true;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    if (!AppConfig.hasSupabase) {
      // No Supabase configured — go straight to home (guest mode)
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    // First, check if a session is already available synchronously
    // (Supabase Flutter restores tokens from secure storage on init)
    final existingSession = Supabase.instance.client.auth.currentSession;
    if (existingSession != null) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    // Otherwise, wait for the auth state to resolve (handles the async
    // token-restore case that can happen on slower devices)
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      final event = data.event;
      if (event == AuthChangeEvent.initialSession) {
        // Session restored from storage → go home
        if (data.session != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // No session → show landing page
          setState(() => _loading = false);
        }
        _authSub?.cancel();
      } else if (event == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
        _authSub?.cancel();
      }
    });

    // Safety fallback: if no auth event fires within 2s, show landing page
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && _loading) {
      setState(() => _loading = false);
      _authSub?.cancel();
    }
  }

  bool get _hasSession {
    if (!AppConfig.hasSupabase) return false;
    return Supabase.instance.client.auth.currentSession != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: Stack(
        children: [
          // Ambient glow top-left
          Positioned(
            top: -100,
            left: -80,
            child: _Glow(color: HeritageColors.orange, size: 340, opacity: 0.18),
          ),
          // Ambient glow bottom-right
          Positioned(
            bottom: -80,
            right: -60,
            child: _Glow(color: const Color(0xFF52B788), size: 280, opacity: 0.10),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    // ── Logo ────────────────────────────────────────────
                    _buildLogo(),
                    const SizedBox(height: 20),
                    Text(
                      'Explore and preserve\nSri Lanka\'s heritage.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const Spacer(flex: 2),
                    // ── Feature pills ───────────────────────────────────
                    _buildFeaturePills(),
                    const Spacer(flex: 3),
                    // ── Action buttons ─────────────────────────────────
                    // Only show when we know there's no session
                    _buildButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF4A261), Color(0xFFE9C46A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: HeritageColors.orange.withValues(alpha: 0.5),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance,
            color: Color(0xFF1A0F05),
            size: 44,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'HeritageLK',
          style: GoogleFonts.plusJakartaSans(
            color: HeritageColors.orange,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'GUARDIAN OF SRI LANKA',
          style: TextStyle(
            color: HeritageColors.brown.withValues(alpha: 0.65),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.0,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePills() {
    const features = [
      ('🏰', 'UNESCO Sites'),
      ('🐆', 'Wildlife'),
      ('🛡️', 'Report Damage'),
      ('🤖', 'Shingo AI'),
      ('📸', 'Heritage Cam'),
      ('🗺️', 'Quests'),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: features.map((f) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(f.$1, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              f.$2,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildButtons() {
    // Show spinner while we're still determining auth state
    if (_loading) {
      return const SizedBox(
        height: 56,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: HeritageColors.orange,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: HeritageColors.orange,
              foregroundColor: const Color(0xFF1A0F05),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Sign In',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pushNamed('/signup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: HeritageColors.orange,
              side: BorderSide(
                color: HeritageColors.orange.withValues(alpha: 0.45),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Create Account',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          child: Text(
            'Continue as Guest',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _Glow({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withValues(alpha: opacity), Colors.transparent],
      ),
    ),
  );
}
