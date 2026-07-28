// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showGeminiConfigDialog() {
    final keyController = TextEditingController(text: AppConfig.userGeminiApiKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1917),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.key, color: Color(0xFFE9C46A)),
            const SizedBox(width: 10),
            Text('Gemini AI Settings', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API Key to enable live generative AI responses for site guides, search, and Shingo AI.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x33E9C46A))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE9C46A))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9C46A),
              foregroundColor: HeritageColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              AppConfig.userGeminiApiKey = keyController.text;
              setState(() {});
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(keyController.text.isNotEmpty ? 'Gemini API Key saved! ⚡' : 'API Key cleared.')),
              );
            },
            child: const Text('Save Key', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Stack(children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 220,
              child: Opacity(
                opacity: 0.6,
                child: Image.network(
                  'https://images.unsplash.com/photo-1586224372551-7f91854580bf?q=80&w=800&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(color: HeritageColors.brown),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [HeritageColors.background, HeritageColors.background.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/profile')),
                    Text('Settings', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 24, fontWeight: FontWeight.bold)),
                    _round(Icons.info_outline, () {}, iconColor: const Color(0xFFE9C46A)),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('HeritageLK App Settings', style: TextStyle(color: HeritageColors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _section(context, 'AI & EXPLORATION ENGINE', [
                  _CustomNavItem(
                    label: 'Gemini AI Configuration',
                    icon: Icons.auto_awesome,
                    subtitle: AppConfig.effectiveGeminiApiKey.isNotEmpty ? 'API Key Active ⚡' : 'Configure Key',
                    onTap: _showGeminiConfigDialog,
                  ),
                ]),
                const SizedBox(height: 32),
                _section(context, 'ACCOUNT', [
                  _CustomNavItem(label: 'Personal Information', icon: Icons.person_outline, onTap: () => Navigator.of(context).pushNamed('/settings/personal')),
                  _CustomNavItem(label: 'Security', icon: Icons.lock_outline, onTap: () => Navigator.of(context).pushNamed('/settings/security')),
                ]),
                const SizedBox(height: 32),
                _section(context, 'PREFERENCES & PRIVACY', [
                  _CustomNavItem(label: 'Notifications', icon: Icons.notifications_none, onTap: () => Navigator.of(context).pushNamed('/settings/notifications')),
                  _CustomNavItem(label: 'Privacy & Data', icon: Icons.shield_outlined, onTap: () => Navigator.of(context).pushNamed('/settings/privacy')),
                ]),
                const SizedBox(height: 32),
                _section(context, 'SUPPORT', [
                  _CustomNavItem(label: 'Help Center', icon: Icons.help_outline, onTap: () => Navigator.of(context).pushNamed('/settings/help')),
                  _CustomNavItem(label: 'Give Feedback', icon: Icons.message_outlined, onTap: () => Navigator.of(context).pushNamed('/settings/help')),
                ]),
                const SizedBox(height: 40),
                InkWell(
                  onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: const Color(0x1AE76F51), border: Border.all(color: const Color(0x33E76F51)), borderRadius: BorderRadius.circular(16)),
                    child: const Row(children: [Icon(Icons.logout, color: Color(0xFFE76F51)), SizedBox(width: 16), Text('Log Out', style: TextStyle(color: Color(0xFFE76F51), fontWeight: FontWeight.bold))]),
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 16, height: 12, decoration: BoxDecoration(color: HeritageColors.orange.withValues(alpha: 0.80), borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 8),
                          const Text('PRESERVE THE LEGACY', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Version 2.4.1 (Pro Build)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ),
      );

  Widget _section(BuildContext context, String title, List<_CustomNavItem> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0x80F4A261), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, color: HeritageColors.orange, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                            if (item.subtitle != null) Text(item.subtitle!, style: const TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_back_ios, color: Colors.white.withValues(alpha: 0.40), size: 14, textDirection: TextDirection.rtl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _round(IconData icon, VoidCallback action, {Color iconColor = HeritageColors.orange}) => InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      );
}

class _CustomNavItem {
  final String label;
  final IconData icon;
  final String? subtitle;
  final VoidCallback onTap;
  const _CustomNavItem({required this.label, required this.icon, this.subtitle, required this.onTap});
}
