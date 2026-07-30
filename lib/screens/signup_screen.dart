// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';
import '../widgets/heritage_auth_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _showPass = false;
  bool _submitting = false;
  bool _emailSent = false;
  String _authMessage = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _authMessage = '';
      _submitting = true;
    });
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
        setState(() {
          _emailSent = true;
          _authMessage = 'Account created. Please check your email to confirm your account.';
          _submitting = false;
        });
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: HeritageAuthShell(
        heroImageUrl: HeritageAuthShell.signupHero,
        brandItalic: true,
        formSection: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Create Account',
              style: TextStyle(
                color: HeritageColors.cream,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Preserve your heritage today.',
              style: TextStyle(color: HeritageColors.brown, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeritageAuthField(
                    controller: _nameCtrl,
                    placeholder: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your name';
                      if (v.trim().length < 2) return 'Name must be at least 2 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  HeritageAuthField(
                    controller: _passCtrl,
                    placeholder: 'Create Password',
                    icon: Icons.lock_outline,
                    obscureText: !_showPass,
                    showObscureToggle: true,
                    obscureVisible: _showPass,
                    onToggleObscure: () => setState(() => _showPass = !_showPass),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please create a password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  HeritageAuthField(
                    controller: _emailCtrl,
                    placeholder: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your email';
                      if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                      return null;
                    },
                  ),
                  if (_authMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_authMessage, style: const TextStyle(color: HeritageColors.orange, fontSize: 14)),
                  ],
                  const SizedBox(height: 24),
                  HeritageAuthPrimaryButton(
                    label: 'Begin Journey',
                    loading: _submitting,
                    onPressed: _signup,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            heritageAuthDivider('or join with'),
            const SizedBox(height: 24),
            const HeritageAuthSocialRow(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?', style: TextStyle(color: HeritageColors.brown, fontSize: 14)),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                  child: const Text(
                    'Log in',
                    style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
              Text(
                'Check your inbox!',
                style: GoogleFonts.plusJakartaSans(
                  color: HeritageColors.cream,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a confirmation link to\n$email',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageColors.orange,
                    foregroundColor: HeritageColors.background,
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
