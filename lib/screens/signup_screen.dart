import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';

class SignupScreen extends StatefulWidget { const SignupScreen({super.key}); @override State<SignupScreen> createState() => _SignupScreenState(); }
class _SignupScreenState extends State<SignupScreen> {
  bool _showPassword = false; bool _submitting = false; String _authMessage = '';
  final _name = TextEditingController(); final _password = TextEditingController(); final _email = TextEditingController();
  @override void dispose() { _name.dispose(); _password.dispose(); _email.dispose(); super.dispose(); }
  Future<void> _signup() async {
    setState(() => _authMessage = '');
    if (!AppConfig.hasSupabase) {
      setState(() => _authMessage = 'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(email: _email.text.trim(), password: _password.text, data: {'full_name': _name.text.trim()});
      final userId = response.user?.id;
      if (userId != null) {
        try {
          await Supabase.instance.client.from('profiles').upsert({'id': userId, 'full_name': _name.text.trim(), 'points': 0});
        } catch (_) {
          // Email-confirmation projects may create the profile after the first signed-in session.
        }
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (error) {
      if (mounted) setState(() => _authMessage = error.message);
    } catch (error) {
      if (mounted) setState(() => _authMessage = '$error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _hero(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Create Account', style: TextStyle(color: HeritageColors.cream, fontSize: 24, fontWeight: FontWeight.bold, height: 1.33)),
                      const SizedBox(height: 4),
                      const Text('Preserve your heritage today.', style: TextStyle(color: HeritageColors.brown, fontSize: 14, height: 1.4)),
                      const SizedBox(height: 24),
                      _field(_name, 'Full Name', Icons.person_outline),
                      const SizedBox(height: 16),
                      _passwordField(),
                      const SizedBox(height: 16),
                      _field(_email, 'Email Address', Icons.email_outlined),
                      if (_authMessage.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_authMessage, style: const TextStyle(color: HeritageColors.orange, fontSize: 13))),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _submitting ? null : _signup,
                          style: FilledButton.styleFrom(
                            backgroundColor: HeritageColors.orange,
                            disabledBackgroundColor: HeritageColors.orange.withOpacity(0.55),
                            foregroundColor: HeritageColors.background,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_submitting ? 'Creating Account...' : 'Begin Journey', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: HeritageColors.brown.withOpacity(0.20))),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR JOIN WITH', style: TextStyle(color: HeritageColors.brown, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6))),
                          Expanded(child: Divider(color: HeritageColors.brown.withOpacity(0.20))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(children: [_social('Google', Icons.g_mobiledata), const SizedBox(width: 16), _social('Apple', Icons.apple)]),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?', style: TextStyle(color: HeritageColors.brown, fontSize: 14)),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                            child: const Text('Log in', style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Widget _hero() => SizedBox(height: 340, child: Stack(fit: StackFit.expand, children: [Image.network('https://api.builder.io/api/v1/image/assets/TEMP/b02856ceecd423ab75d2e1d643e2e881960878b0?width=880', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.60), errorBuilder: (_, __, ___) => const ColoredBox(color: HeritageColors.background)), const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x66100E0A), Color(0x00100E0A), HeritageColors.background]))), const Positioned(left: 24, bottom: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('HeritageLK', style: TextStyle(color: HeritageColors.orange, fontStyle: FontStyle.italic, fontFamily: 'Inter', fontSize: 32, height: 1.4)), Text('JOIN THE LEGACY', style: TextStyle(color: HeritageColors.brown, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.35))]))]));
  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(hintText: hint, hintStyle: TextStyle(color: HeritageColors.brown.withOpacity(0.50)), prefixIcon: Icon(icon, color: HeritageColors.brown, size: 18), filled: true, fillColor: HeritageColors.brown.withOpacity(0.10), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: HeritageColors.brown.withOpacity(0.30)), borderRadius: BorderRadius.circular(16)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: HeritageColors.orange.withOpacity(0.50)), borderRadius: BorderRadius.circular(16)));
  Widget _field(TextEditingController controller, String hint, IconData icon) => TextField(controller: controller, style: const TextStyle(color: HeritageColors.cream, fontSize: 16), decoration: _decoration(hint, icon));
  Widget _passwordField() => TextField(controller: _password, obscureText: !_showPassword, style: const TextStyle(color: HeritageColors.cream, fontSize: 16), decoration: _decoration('Create Password', Icons.lock_outline).copyWith(suffixIcon: IconButton(onPressed: () => setState(() => _showPassword = !_showPassword), color: HeritageColors.brown.withOpacity(0.50), icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, size: 18))));
  Widget _social(String text, IconData icon) => Expanded(
    child: SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: HeritageColors.cream),
        label: Text(text, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          backgroundColor: HeritageColors.brown.withOpacity(0.10),
          side: BorderSide(color: HeritageColors.brown.withOpacity(0.30)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ),
  );
}
