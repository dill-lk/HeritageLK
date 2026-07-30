import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
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
  bool _twoFactor = false;
  bool _biometric = true;
  bool _dataSharing = false;

  String _fullName = 'Explorer';
  String _email = 'explorer@heritagelk.com';
  String _city = 'Galle';
  String _bio = 'Heritage explorer and protector';
  bool _profileLoaded = false;

  final _feedbackCtrl = TextEditingController();
  String _feedbackCategory = 'General';

  @override
  void initState() {
    super.initState();
    if (widget.title == 'Personal Information') {
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!AppConfig.hasSupabase) {
      setState(() => _profileLoaded = true);
      return;
    }
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = session?.user;
      if (user == null) {
        setState(() => _profileLoaded = true);
        return;
      }
      final metaName = user.userMetadata?['full_name'] as String?;
      final email = user.email ?? _email;
      var name = metaName ?? email.split('@').first;
      var city = _city;
      var bio = _bio;

      final row = await Supabase.instance.client
          .from('profiles')
          .select('full_name, city, bio')
          .eq('id', user.id)
          .maybeSingle();
      if (row != null) {
        if (row['full_name'] != null && row['full_name'].toString().isNotEmpty) {
          name = row['full_name'] as String;
        }
        if (row['city'] != null) city = row['city'] as String;
        if (row['bio'] != null) bio = row['bio'] as String;
      }

      if (!mounted) return;
      setState(() {
        _fullName = name;
        _email = email;
        _city = city;
        _bio = bio;
        _profileLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _profileLoaded = true);
    }
  }

  void _submitFeedback() {
    final text = _feedbackCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share your feedback before sending.')),
      );
      return;
    }
    _feedbackCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thank you! Your $_feedbackCategory feedback was recorded.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItemsForTitle(widget.title);
    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Row(children: [
              _round(Icons.arrow_back, () => Navigator.of(context).pop()),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: HeritageColors.cream,
                    fontFamily: 'Playfair Display',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: const TextStyle(color: Color(0x99FEFAE0), fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 24),
            if (widget.title == 'Personal Information' && !_profileLoaded)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: HeritageColors.orange)))
            else
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
          _infoField('Full Name', _fullName, Icons.person_outline),
          const SizedBox(height: 12),
          _infoField('Email', _email, Icons.email_outlined),
          const SizedBox(height: 12),
          _infoField('City', _city, Icons.location_city_outlined),
          const SizedBox(height: 12),
          _infoField('Bio', _bio, Icons.edit_outlined),
          const SizedBox(height: 20),
          _action('Edit Profile', 'Update name, city, and bio on your profile', Icons.edit_outlined),
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
      case 'Help Center':
        return [
          _action('Getting Started', 'Learn quests, points, and your passport', Icons.play_circle_outline),
          const SizedBox(height: 12),
          _action('Heritage Scanner', 'How to identify sites with AI', Icons.document_scanner_outlined),
          const SizedBox(height: 12),
          _action('Report Damage', 'Submit and track conservation reports', Icons.report_outlined),
          const SizedBox(height: 12),
          _action('Account & Login', 'Sign in, password reset, and profile', Icons.login_outlined),
          const SizedBox(height: 12),
          _action('Contact Support', 'support@heritagelk.com', Icons.support_agent_outlined),
        ];
      case 'Give Feedback':
        return [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _feedbackCategory,
                  dropdownColor: const Color(0xFF1E1B18),
                  style: const TextStyle(color: HeritageColors.cream, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: ['General', 'Bug Report', 'Feature Request', 'Heritage Content']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _feedbackCategory = v);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Your message', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 8),
                TextField(
                  controller: _feedbackCtrl,
                  maxLines: 5,
                  style: const TextStyle(color: HeritageColors.cream, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tell us what you think about HeritageLK...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HeritageColors.orange,
                      foregroundColor: HeritageColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Send Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ];
      case 'About HeritageLK':
        return [
          _action('Version', '2.4.1 (Stable Build)', Icons.info_outline),
          const SizedBox(height: 12),
          _action('Mission', 'Preserve and celebrate Sri Lankan heritage', Icons.flag_outlined),
          const SizedBox(height: 12),
          _action('Terms of Service', 'Read our terms', Icons.description_outlined),
          const SizedBox(height: 12),
          _action('Privacy Policy', 'How we protect your data', Icons.privacy_tip_outlined),
          const SizedBox(height: 12),
          _action('Open Source Licenses', 'Third-party libraries', Icons.code_outlined),
        ];
      default:
        return [
          _action('About HeritageLK', 'Version 2.4.1 - Stable Build', Icons.info_outline),
        ];
    }
  }

  Widget _toggle(String label, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: HeritageColors.orange, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
                ],
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: Colors.white,
              activeTrackColor: HeritageColors.orange,
              onChanged: onChanged,
            ),
          ],
        ),
      );

  Widget _infoField(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: HeritageColors.orange, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: HeritageColors.cream, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0x4DFFFFFF), size: 18),
          ],
        ),
      );

  Widget _action(String label, String subtitle, IconData icon) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: HeritageColors.orange, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0x4DFFFFFF), size: 18),
          ],
        ),
      );

  Widget _round(IconData icon, VoidCallback action) => InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), shape: BoxShape.circle),
          child: Icon(icon, color: HeritageColors.orange, size: 20),
        ),
      );
}
