import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/heritage_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Stack(children: [
        Positioned(top: 0, left: 0, right: 0, height: 220, child: Opacity(opacity: 0.6, child: Image.network('https://images.unsplash.com/photo-1586224372551-7f91854580bf?q=80&w=800&auto=format&fit=crop', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: HeritageColors.brown)))),
        Positioned(top: 0, left: 0, right: 0, height: 220, child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [HeritageColors.background, HeritageColors.background.withValues(opacity:0)])))),
        ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 32), children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/profile')),
            Text('Settings', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 24, fontWeight: FontWeight.bold)),
            _round(Icons.info_outline, () {}, iconColor: const Color(0xFFE9C46A)),
          ]),
          const SizedBox(height: 32),
          const Text('HeritageLK', style: TextStyle(color: HeritageColors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('EDIT PROFILE', style: TextStyle(color: Color(0x80F4A261), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 24),
          Row(children: [
            ClipOval(child: Image.network('https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=200&auto=format&fit=crop', width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CircleAvatar(backgroundColor: HeritageColors.brown, child: Icon(Icons.person, color: HeritageColors.cream)))),
            const SizedBox(width: 16),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Explorer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Curator Level 4', style: TextStyle(color: Color(0x80F4A261), fontSize: 14)),
            ]),
          ]),
          const SizedBox(height: 40),
          _section(context, 'ACCOUNT', [
            _NavItem('Personal Information', Icons.person_outline, '/settings/personal'),
            _NavItem('Security', Icons.lock_outline, '/settings/security'),
          ]),
          const SizedBox(height: 32),
          _section(context, 'PREFERENCES & PRIVACY', [
            _NavItem('Notifications', Icons.notifications_none, '/settings/notifications'),
            _NavItem('Privacy & Data', Icons.shield_outlined, '/settings/privacy'),
          ]),
          const SizedBox(height: 32),
          _section(context, 'SUPPORT', [
            _NavItem('Help Center', Icons.help_outline, '/settings/help'),
            _NavItem('Give a Feedback', Icons.message_outlined, '/settings/help'),
            _NavItem('About HeritageLK', Icons.info_outline, '/settings/help'),
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
          Center(child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 16, height: 12, decoration: BoxDecoration(color: HeritageColors.orange.withValues(opacity:0.80), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              const Text('PRESERVE THE LEGACY', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ]),
            const SizedBox(height: 4),
            const Text('Version 2.4.1 (Stable Build)', style: TextStyle(color: Colors.white38, fontSize: 10)),
          ])),
        ]),
      ]),
    ),
  );

  Widget _section(BuildContext context, String title, List<_NavItem> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: Color(0x80F4A261), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
    const SizedBox(height: 12),
    ...items.map((item) => Container(margin: const EdgeInsets.only(bottom: 8), child: InkWell(onTap: () => Navigator.of(context).pushNamed(item.route), borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(opacity:0.05), border: Border.all(color: Colors.white.withValues(opacity:0.05)), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(item.icon, color: HeritageColors.orange, size: 20), const SizedBox(width: 16), Expanded(child: Text(item.label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))), Icon(Icons.arrow_back_ios, color: Colors.white.withValues(opacity:0.40), size: 14, textDirection: TextDirection.rtl)])))))]);
  Widget _round(IconData icon, VoidCallback action, {Color iconColor = HeritageColors.orange}) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(opacity:0.10), border: Border.all(color: Colors.white.withValues(opacity:0.10)), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)));
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}
