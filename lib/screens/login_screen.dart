// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _submitting = false;
  bool _resetSent = false;
  String _authMessage = '';

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  @override
  void dispose() {
    _anim.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _authMessage = ''; _submitting = true; });
    HapticFeedback.lightImpact();
    try {
      if (!AppConfig.hasSupabase) throw Exception('Account service not available.');
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (e) {
      if (mounted) setState(() => _authMessage = _friendly(e.message));
    } catch (e) {
      if (mounted) setState(() => _authMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _authMessage = 'Enter your email address first, then tap Forgot password.');
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) setState(() { _resetSent = true; _authMessage = ''; });
    } on AuthException catch (e) {
      if (mounted) setState(() => _authMessage = _friendly(e.message));
    } catch (_) {}
  }

  String _friendly(String msg) {
    if (msg.contains('Invalid login')) return 'Wrong email or password. Please try again.';
    if (msg.contains('Email not confirmed')) return 'Please confirm your email first.';
    if (msg.contains('Too many')) return 'Too many attempts — wait a minute and try again.';
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.background,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // ── Ambient glows ──────────────────────────────────────────
            Positioned(
              top: -100,
              left: -80,
              child: _Glow(color: HeritageColors.orange, size: 320, opacity: 0.15),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: _Glow(color: const Color(0xFF52B788), size: 260, opacity: 0.08),
            ),
            // ── Content ────────────────────────────────────────────────
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
                          .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic)),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 44),
                            _buildHeading(),
                            const SizedBox(height: 28),
                            _buildForm(),
                            const SizedBox(height: 24),
                            _buildDivider(),
                            const SizedBox(height: 20),
                            Row(children: [
                              _SocialBtn(label: 'Google', icon: Icons.g_mobiledata),
                              const SizedBox(width: 12),
                              _SocialBtn(label: 'Apple', icon: Icons.apple),
                            ]),
                            const SizedBox(height: 32),
                            _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() => Column(children: [
    Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF4A261), Color(0xFFE9C46A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: HeritageColors.orange.withValues(alpha: 0.45), blurRadius: 28, offset: const Offset(0, 8))],
      ),
      child: const Icon(Icons.account_balance, color: Color(0xFF1A0F05), size: 34),
    ),
    const SizedBox(height: 12),
    Text('HeritageLK', style: GoogleFonts.plusJakartaSans(color: HeritageColors.orange, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
    const SizedBox(height: 4),
    Text('GUARDIAN OF SRI LANKA', style: TextStyle(color: HeritageColors.brown.withValues(alpha: 0.65), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2.5)),
  ]);

  Widget _buildHeading() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Welcome back 👋', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 27, fontWeight: FontWeight.bold, height: 1.2)),
    const SizedBox(height: 6),
    Text('Sign in to continue your heritage journey', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 14, height: 1.4)),
  ]);

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(
            controller: _emailController,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _Field(
            controller: _passwordController,
            hint: 'Password',
            icon: Icons.lock_outlined,
            obscureText: !_showPassword,
            validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
            suffix: IconButton(
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(_showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: 0.35), size: 20),
            ),
          ),
          // Error banners
          if (_authMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Banner(text: _authMessage, isError: true),
          ],
          if (_resetSent) ...[
            const SizedBox(height: 12),
            _Banner(text: 'Password reset sent! Check your inbox.', isError: false),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6)),
              child: Text('Forgot password?', style: TextStyle(color: HeritageColors.orange.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: _submitting
                ? Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: HeritageColors.orange, strokeWidth: 2.5)))
                : ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HeritageColors.orange,
                      foregroundColor: const Color(0xFF1A0F05),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Sign In', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Row(children: [
    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text('or continue with', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
    ),
    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
  ]);

  Widget _buildFooter() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text("Don't have an account?", style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
    TextButton(
      onPressed: () => Navigator.of(context).pushReplacementNamed('/signup'),
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
      child: Text('Sign up', style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold)),
    ),
  ]);
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: HeritageColors.cream, fontSize: 15),
      cursorColor: HeritageColors.orange,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.38), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: HeritageColors.orange, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE76F51), width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE76F51), width: 1.5)),
        errorStyle: const TextStyle(color: Color(0xFFE76F51), fontSize: 12),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final bool isError;
  const _Banner({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    final c = isError ? const Color(0xFFE76F51) : const Color(0xFF52B788);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: c, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: c, fontSize: 13))),
      ]),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SocialBtn({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.65), size: 22),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
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
      gradient: RadialGradient(colors: [color.withValues(alpha: opacity), Colors.transparent]),
    ),
  );
}
