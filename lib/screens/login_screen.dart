import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showPassword = false;
  bool _languageOpen = false;
  bool _submitting = false;
  String _language = 'English';
  String _authMessage = '';
  bool _resetSent = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _authMessage = '');
    if (!AppConfig.hasSupabase) {
      setState(() => _authMessage = 'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: _emailController.text.trim(), password: _passwordController.text);
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (error) {
      if (mounted) setState(() => _authMessage = error.message);
    } catch (error) {
      if (mounted) setState(() => _authMessage = '$error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (!AppConfig.hasSupabase || _emailController.text.trim().isEmpty) {
      setState(() => _authMessage = 'Enter your email above, then tap Forgot Password.');
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(_emailController.text.trim());
      if (mounted) setState(() { _resetSent = true; _authMessage = ''; });
    } on AuthException catch (error) {
      if (mounted) setState(() => _authMessage = error.message);
    } catch (error) {
      if (mounted) setState(() => _authMessage = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            color: HeritageColors.background,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _hero(context),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                    child: _form(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://api.builder.io/api/v1/image/assets/TEMP/b02856ceecd423ab75d2e1d643e2e881960878b0?width=880',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.60),
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: HeritageColors.background,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66100E0A),
                  Color(0x00100E0A),
                  HeritageColors.background,
                ],
              ),
            ),
          ),
          Positioned(
            top: 56,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _languageSelector(),
                _roundIcon(Icons.info_outline),
              ],
            ),
          ),
          const Positioned(
            left: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HeritageLK',
                  style: TextStyle(
                    color: HeritageColors.orange,
                    fontFamily: 'Inter',
                    fontSize: 32,
                    height: 1.25,
                  ),
                ),
                Text(
                  'JOIN THE LEGACY',
                  style: TextStyle(
                    color: HeritageColors.brown,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_languageOpen)
          Container(
            constraints: const BoxConstraints(minWidth: 132),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.58),
              border: Border.all(color: HeritageColors.orange.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: ['English', 'සිංහල', 'தமிழ்']
                  .map(
                    (language) => InkWell(
                      onTap: () => setState(() {
                        _language = language;
                        _languageOpen = false;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          children: [
                            const Icon(Icons.language, size: 17, color: HeritageColors.orange),
                            const SizedBox(width: 8),
                            Text(language, style: const TextStyle(color: Color(0xFFCA895B))),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        else
          InkWell(
            onTap: () => setState(() => _languageOpen = true),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: HeritageColors.brown.withOpacity(0.15),
                border: Border.all(color: HeritageColors.orange.withOpacity(0.20)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 17, color: HeritageColors.orange),
                  const SizedBox(width: 8),
                  Text(_language, style: const TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down, size: 14, color: HeritageColors.orange),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _roundIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: HeritageColors.brown.withOpacity(0.15),
        border: Border.all(color: HeritageColors.orange.withOpacity(0.10)),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: HeritageColors.orange),
    );
  }

  Widget _form(BuildContext context) {
    final inputDecoration = (String hint, IconData icon) => InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: HeritageColors.brown.withOpacity(0.50)),
          prefixIcon: Icon(icon, size: 18, color: HeritageColors.brown),
          filled: true,
          fillColor: HeritageColors.brown.withOpacity(0.10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HeritageColors.brown.withOpacity(0.30)),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HeritageColors.orange.withOpacity(0.50)),
            borderRadius: BorderRadius.circular(16),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Welcome Back', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 24, fontWeight: FontWeight.bold, height: 1.5)),
        const Text('Continue your journey through history.', style: TextStyle(color: HeritageColors.brown, fontSize: 14, height: 1.5)),
        const SizedBox(height: 24),
        TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: inputDecoration('Enter Email', Icons.person_outline)),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: inputDecoration('Enter Password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              onPressed: () => setState(() => _showPassword = !_showPassword),
              color: HeritageColors.brown.withOpacity(0.50),
              icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, size: 18),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_authMessage.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_authMessage, style: const TextStyle(color: HeritageColors.orange, fontSize: 13))),
        if (_resetSent) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('Password reset email sent. Check your inbox.', style: TextStyle(color: const Color(0xFF52B788), fontSize: 13))),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _forgotPassword, child: const Text('Forgot Password?', style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.w600)))),
        const SizedBox(height: 10),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _submitting ? null : _signIn,
            style: FilledButton.styleFrom(backgroundColor: HeritageColors.orange, disabledBackgroundColor: HeritageColors.orange.withOpacity(0.55), foregroundColor: HeritageColors.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_submitting ? 'Signing In...' : 'Sign In', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 18)]),
          ),
        ),
        const SizedBox(height: 24),
        Row(children: [Expanded(child: Divider(color: HeritageColors.brown.withOpacity(0.20))), const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('or sign in with', style: TextStyle(color: HeritageColors.brown, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6))), Expanded(child: Divider(color: HeritageColors.brown.withOpacity(0.20)))]),
        const SizedBox(height: 24),
        Row(children: [_socialButton('Google', Icons.g_mobiledata), const SizedBox(width: 16), _socialButton('Apple', Icons.apple)]),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Don't have an account?", style: TextStyle(color: HeritageColors.brown, fontSize: 14)), TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/signup'), child: const Text('Sign up', style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold)))]),
      ],
    );
  }

  Widget _socialButton(String label, IconData icon) {
    return Expanded(
      child: SizedBox(
        height: 56,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(icon, color: HeritageColors.cream),
          label: Text(label, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            backgroundColor: HeritageColors.brown.withOpacity(0.10),
            side: BorderSide(color: HeritageColors.brown.withOpacity(0.30)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}
