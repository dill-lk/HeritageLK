// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showPass = false;
  bool _showConfirm = false;
  bool _submitting = false;
  bool _emailSent = false;
  String _authMessage = '';

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  @override
  void dispose() {
    _anim.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _authMessage = ''; _submitting = true; });
    HapticFeedback.lightImpact();
    try {
      if (!AppConfig.hasSupabase) throw Exception('Account service unavailable.');
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        data: {'full_name': _nameCtrl.text.trim()},
      );
      final uid = res.user?.id;
      if (uid != null) {
        try {
          await Supabase.instance.client.from('profiles').upsert({
            'id': uid,
            'full_name': _nameCtrl.text.trim(),
            'points': 0,
          });
        } catch (_) {}
      }
      if (!mounted) return;
      if (res.session == null) {
        // Email confirmation required
        setState(() { _emailSent = true; _submitting = false; });
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _authMessage = _friendly(e.message));
    } catch (e) {
      if (mounted) setState(() => _authMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _friendly(String msg) {
    if (msg.contains('already registered')) return 'This email is already in use. Try signing in instead.';
    if (msg.contains('Password should be')) return 'Password must be at least 6 characters.';
    if (msg.contains('valid email')) return 'Please enter a valid email address.';
    if (msg.contains('Too many')) return 'Too many attempts. Please wait a moment.';
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    if (_emailSent) return _EmailConfirmScreen(email: _emailCtrl.text.trim());
    return Scaffold(
      backgroundColor: HeritageColors.background,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(top: -90, right: -70, child: _Glow(color: HeritageColors.orange, size: 300, opacity: 0.14)),
            Positioned(bottom: -70, left: -60, child: _Glow(color: const Color(0xFF52B788), size: 240, opacity: 0.07)),
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
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBackButton(),
                            const SizedBox(height: 24),
                            _buildLogoRow(),
                            const SizedBox(height: 30),
                            _buildHeading(),
                            const SizedBox(height: 24),
                            _buildForm(),
                            const SizedBox(height: 24),
                            _buildDivider(),
                            const SizedBox(height: 18),
                            Row(children: [
                              _SocialBtn(label: 'Google', icon: Icons.g_mobiledata),
                              const SizedBox(width: 12),
                              _SocialBtn(label: 'Apple', icon: Icons.apple),
                            ]),
                            const SizedBox(height: 28),
                            _buildLoginLink(),
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

  Widget _buildBackButton() => Align(
    alignment: Alignment.centerLeft,
    child: GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.7), size: 20),
      ),
    ),
  );

  Widget _buildLogoRow() => Row(children: [
    Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF4A261), Color(0xFFE9C46A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: HeritageColors.orange.withValues(alpha: 0.38), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: const Icon(Icons.account_balance, color: Color(0xFF1A0F05), size: 22),
    ),
    const SizedBox(width: 12),
    Text('HeritageLK', style: GoogleFonts.plusJakartaSans(color: HeritageColors.orange, fontSize: 22, fontWeight: FontWeight.w800)),
  ]);

  Widget _buildHeading() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Create account ✨', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
    const SizedBox(height: 6),
    Text("Join the guardians of Sri Lanka's heritage", style: TextStyle(color: Colors.white.withValues(alpha: 0.42), fontSize: 14, height: 1.4)),
  ]);

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(
            controller: _nameCtrl,
            hint: 'Full name',
            icon: Icons.person_outline_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your name';
              if (v.trim().length < 2) return 'Name must be at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _emailCtrl,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _passCtrl,
            hint: 'Password',
            icon: Icons.lock_outlined,
            obscureText: !_showPass,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please create a password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
            suffix: IconButton(
              onPressed: () => setState(() => _showPass = !_showPass),
              icon: Icon(_showPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: 0.35), size: 20),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _confirmCtrl,
            hint: 'Confirm password',
            icon: Icons.lock_outlined,
            obscureText: !_showConfirm,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passCtrl.text) return 'Passwords do not match';
              return null;
            },
            suffix: IconButton(
              onPressed: () => setState(() => _showConfirm = !_showConfirm),
              icon: Icon(_showConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: 0.35), size: 20),
            ),
          ),
          if (_authMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Banner(text: _authMessage, isError: true),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: _submitting
                ? Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: HeritageColors.orange, strokeWidth: 2.5)))
                : ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HeritageColors.orange,
                      foregroundColor: const Color(0xFF1A0F05),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Begin Journey 🏛️', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
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
      child: Text('or sign up with', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
    ),
    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
  ]);

  Widget _buildLoginLink() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('Already have an account?', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
    TextButton(
      onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
      child: Text('Sign in', style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold)),
    ),
  ]);
}

// ── Email confirm screen ──────────────────────────────────────────────────────
class _EmailConfirmScreen extends StatelessWidget {
  final String email;
  const _EmailConfirmScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF52B788).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF52B788).withValues(alpha: 0.35)),
                ),
                child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF52B788), size: 36),
              ),
              const SizedBox(height: 24),
              Text('Check your inbox!',
                  style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('We sent a confirmation link to\n$email',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 14, height: 1.6)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageColors.orange,
                    foregroundColor: const Color(0xFF1A0F05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Go to Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => TextFormField(
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
