// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';
import '../widgets/heritage_auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _submitting = false;
  String _authMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _authMessage = '';
      _submitting = true;
    });
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

  String _friendly(String msg) {
    if (msg.contains('Invalid login')) return 'Wrong email or password. Please try again.';
    if (msg.contains('Email not confirmed')) return 'Please confirm your email first.';
    if (msg.contains('Too many')) return 'Too many attempts — wait a minute and try again.';
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: HeritageAuthShell(
        heroImageUrl: HeritageAuthShell.loginHero,
        formSection: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Welcome Back',
              style: TextStyle(
                color: HeritageColors.cream,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Continue your journey through history.',
              style: TextStyle(color: HeritageColors.brown, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeritageAuthField(
                    controller: _emailController,
                    placeholder: 'Enter Email',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  HeritageAuthField(
                    controller: _passwordController,
                    placeholder: 'Enter Password',
                    icon: Icons.lock_outline,
                    obscureText: !_showPassword,
                    showObscureToggle: true,
                    obscureVisible: _showPassword,
                    onToggleObscure: () => setState(() => _showPassword = !_showPassword),
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
                  ),
                  if (_authMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_authMessage, style: const TextStyle(color: HeritageColors.orange, fontSize: 14)),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset will be sent to your email when configured.')),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  HeritageAuthPrimaryButton(
                    label: 'Sign In',
                    loading: _submitting,
                    onPressed: _signIn,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            heritageAuthDivider('or sign in with'),
            const SizedBox(height: 24),
            const HeritageAuthSocialRow(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?", style: TextStyle(color: HeritageColors.brown, fontSize: 14)),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/signup'),
                  child: const Text(
                    'Sign up',
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
