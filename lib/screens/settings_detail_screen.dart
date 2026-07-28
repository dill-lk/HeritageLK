import 'package:flutter/material.dart';

import '../theme/heritage_colors.dart';

class SettingsDetailScreen extends StatefulWidget {
  const SettingsDetailScreen({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  State<SettingsDetailScreen> createState() => _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends State<SettingsDetailScreen> {
  bool _notifications = true;
  bool _location = true;
  bool _profileVisibility = true;
  bool _recommendations = false;
  bool _darkMode = true;
  bool _twoFactor = false;
  bool _biometric = true;
  bool _dataSharing = false;

  @override
  Widget build(BuildContext context) {
    final items = _getItemsForTitle(widget.title);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Row(children: [
              _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/settings')),
              const SizedBox(width: 16),
              Expanded(child: Text(widget.title, style: const TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 22, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 12),
            Text(widget.description, style: const TextStyle(color: Color(0x99FEFAE0), fontSize: 14, height: 1.6)),
            const SizedBox(height: 24),
            ...items,
          ],
        ),
      ),
    );
  }

  List<Widget> _getItemsForTitle(String title) {
    switch (title) {
      case 'Personal Information':
        return [
          _infoField('Full Name', 'Explorer', Icons.person_outline),
          const SizedBox(height: 12),
          _infoField('Email', 'explorer@heritagelk.com', Icons.email_outlined),
          const SizedBox(height: 12),
          _infoField('City', 'Galle', Icons.location_city_outlined),
          const SizedBox(height: 12),
          _infoField('Bio', 'Heritage explorer and protector', Icons.edit_outlined),
        ];
      case 'Security':
        return [
          _toggle('Two-Factor Authentication', 'Add an extra layer of security', _twoFactor, (v) => setState(() => _twoFactor = v), Icons.shield_outlined),
          const SizedBox(height: 12),
          _toggle('Biometric Login', 'Use fingerprint or face to sign in', _biometric, (v) => setState(() => _biometric = v), Icons.fingerprint),
          const SizedBox(height: 12),
          _action('Change Password', 'Update your password regularly', Icons.lock_outline),
          const SizedBox(height: 12),
          _action('Active Sessions', 'Manage your signed-in devices', Icons.devices_outlined),
        ];
      case 'Notifications':
        return [
          _toggle('Push Notifications', 'Get notified about quest updates', _notifications, (v) => setState(() => _notifications = v), Icons.notifications_none),
          const SizedBox(height: 12),
          _toggle('Email Notifications', 'Receive heritage news via email', _notifications, (v) => setState(() => _notifications = v), Icons.email_outlined),
          const SizedBox(height: 12),
          _toggle('Damage Alerts', 'Get alerts for nearby damage reports', _notifications, (v) => setState(() => _notifications = v), Icons.warning_amber_outlined),
          const SizedBox(height: 12),
          _toggle('Leaderboard Updates', 'Know when your rank changes', _notifications, (v) => setState(() => _notifications = v), Icons.leaderboard_outlined),
        ];
      case 'Privacy & Data':
        return [
          _toggle('Profile Visibility', 'Show your profile to other explorers', _profileVisibility, (v) => setState(() => _profileVisibility = v), Icons.visibility_outlined),
          const SizedBox(height: 12),
          _toggle('Location Services', 'Allow GPS for heritage site detection', _location, (v) => setState(() => _location = v), Icons.location_on_outlined),
          const SizedBox(height: 12),
          _toggle('Personalized Recommendations', 'AI-powered heritage suggestions', _recommendations, (v) => setState(() => _recommendations = v), Icons.auto_awesome),
          const SizedBox(height: 12),
          _toggle('Anonymous Data Sharing', 'Help improve HeritageLK', _dataSharing, (v) => setState(() => _dataSharing = v), Icons.analytics_outlined),
        ];
      default:
        return [
          _toggle('Dark Mode', 'Use dark theme throughout the app', _darkMode, (v) => setState(() => _darkMode = v), Icons.dark_mode_outlined),
          const SizedBox(height: 12),
          _action('About HeritageLK', 'Version 2.4.1 - Stable Build', Icons.info_outline),
          const SizedBox(height: 12),
          _action('Terms of Service', 'Read our terms', Icons.description_outlined),
          const SizedBox(height: 12),
          _action('Privacy Policy', 'How we protect your data', Icons.privacy_tip_outlined),
        ];
    }
  }

  Widget _toggle(String label, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withValues(opacity:0.05), border: Border.all(color: Colors.white.withValues(opacity:0.07)), borderRadius: BorderRadius.circular(16)), child: Row(children: [
    Icon(icon, color: HeritageColors.orange, size: 20),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(subtitle, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
    ])),
    Switch(value: value, activeThumbColor: Colors.white, activeTrackColor: HeritageColors.orange, onChanged: onChanged),
  ]));

  Widget _infoField(String label, String value, IconData icon) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withValues(opacity:0.05), border: Border.all(color: Colors.white.withValues(opacity:0.07)), borderRadius: BorderRadius.circular(16)), child: Row(children: [
    Icon(icon, color: HeritageColors.orange, size: 20),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: HeritageColors.cream, fontSize: 14)),
    ])),
    const Icon(Icons.chevron_right, color: Color(0x4DFFFFFF), size: 18),
  ]));

  Widget _action(String label, String subtitle, IconData icon) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withValues(opacity:0.05), border: Border.all(color: Colors.white.withValues(opacity:0.07)), borderRadius: BorderRadius.circular(16)), child: Row(children: [
    Icon(icon, color: HeritageColors.orange, size: 20),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(subtitle, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
    ])),
    const Icon(Icons.chevron_right, color: Color(0x4DFFFFFF), size: 18),
  ]));

  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(opacity:0.10), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));
}
