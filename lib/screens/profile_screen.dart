// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/damage_report.dart';
import '../models/profile.dart';
import '../models/user_quest.dart';
import '../services/damage_report_repository.dart';
import '../services/profile_repository.dart';
import '../services/quest_repository.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  Profile? _profile;
  List<UserQuest> _completed = const [];
  List<DamageReport> _userReports = const [];
  int _rank = 0;
  String _selectedAvatarEmoji = '🦁';
  String _customBio = 'Passionate explorer preserving Sri Lanka\'s ancient wonders.';
  late final AnimationController _avatarController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
  late final Animation<double> _avatarScale = CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut);

  final List<Map<String, String>> _culturalAvatars = const [
    {'emoji': '🦁', 'name': 'Sigiriya Lion'},
    {'emoji': '🛕', 'name': 'Sacred Stupa'},
    {'emoji': '🎭', 'name': 'Heritage Mask'},
    {'emoji': '🐘', 'name': 'Wild Elephant'},
    {'emoji': '🪷', 'name': 'Royal Lotus'},
    {'emoji': '👑', 'name': 'Kandyan Monarch'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _avatarController.forward();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!AppConfig.hasSupabase) return;
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentSession == null) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      final profileRepo = ProfileRepository(client);
      final profile = await profileRepo.currentProfile();
      final completed = await QuestRepository(client).completedQuests();
      final rank = profile == null ? 0 : await profileRepo.rankForPoints(profile.points);
      List<DamageReport> reports = [];
      try {
        reports = await DamageReportRepository(client).list();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _profile = profile;
          _completed = completed;
          _userReports = reports;
          _rank = rank;
        });
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    if (AppConfig.hasSupabase) await ProfileRepository(Supabase.instance.client).signOut();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  String _getDisplayName() {
    final user = AppConfig.hasSupabase ? Supabase.instance.client.auth.currentUser : null;
    final profileName = _profile?.fullName;
    if (profileName != null && profileName.isNotEmpty) return profileName;
    final metaName = user?.userMetadata?['full_name']?.toString();
    if (metaName != null && metaName.isNotEmpty) return metaName;
    final email = user?.email;
    if (email != null && email.isNotEmpty) {
      final local = email.split('@').first;
      if (local.isNotEmpty) return local;
    }
    return 'Lankan Explorer';
  }

  String _getRankTitle(int points) {
    if (points >= 1000) return 'Master Heritage Custodian';
    if (points >= 500) return 'Ancient Guardian';
    if (points >= 200) return 'Heritage Explorer';
    if (points >= 50) return 'Cultural Wayfarer';
    return 'Novice Explorer';
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _getDisplayName());
    final bioController = TextEditingController(text: _customBio);
    String tempEmoji = _selectedAvatarEmoji;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1917),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: HeritageColors.orange),
              const SizedBox(width: 10),
              Text('Edit Explorer Profile', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 20)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose Avatar Badge', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _culturalAvatars.map((av) {
                    final selected = av['emoji'] == tempEmoji;
                    return GestureDetector(
                      onTap: () => setDialogState(() => tempEmoji = av['emoji']!),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected ? HeritageColors.orange.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(color: selected ? HeritageColors.orange : Colors.white10, width: selected ? 2 : 1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(av['emoji']!, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Display Name', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HeritageColors.orange)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Explorer Bio / Motto', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: bioController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HeritageColors.orange)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HeritageColors.orange,
                foregroundColor: HeritageColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                setState(() {
                  _selectedAvatarEmoji = tempEmoji;
                  _customBio = bioController.text.trim();
                  if (nameController.text.trim().isNotEmpty) {
                    _profile = Profile(
                      id: _profile?.id ?? 'local',
                      fullName: nameController.text.trim(),
                      points: _profile?.points ?? 150,
                      city: _profile?.city,
                    );
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
              },
              child: const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

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
            Text('Gemini AI Setup', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure your Google Gemini API Key for instant AI heritage analysis, site summaries, and Shingo AI responses.',
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
                SnackBar(content: Text(keyController.text.isNotEmpty ? 'Gemini API Key updated! ⚡' : 'API Key cleared.')),
              );
            },
            child: const Text('Save Key', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = _profile?.points ?? 150;
    final level = points <= 0 ? 1 : (points ~/ 100).clamp(1, 999);
    final progress = points % 100;
    final levelProgress = progress / 100;
    final rankTitle = _getRankTitle(points);

    return Scaffold(
      backgroundColor: const Color(0xFF100E0A),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      HeritageColors.orange.withValues(alpha: 0.15),
                      const Color(0xFF100E0A),
                    ],
                  ),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildHeroProfileCard(level, levelProgress, points, rankTitle),
                const SizedBox(height: 32),
                _buildStatsRow(points),
                const SizedBox(height: 32),
                _buildGeminiAiCard(),
                const SizedBox(height: 32),
                _buildAchievementsSection(),
                const SizedBox(height: 32),
                _buildDamageReportsSection(),
                const SizedBox(height: 32),
                _buildRecentDiscoveriesSection(),
                const SizedBox(height: 32),
                _buildQuickActions(),
                const SizedBox(height: 32),
                _buildLogoutButton(_logout),
              ],
            ),
            const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')),
        Text(
          'Explorer Profile',
          style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        _round(Icons.edit, _showEditProfileDialog),
      ],
    );
  }

  Widget _buildHeroProfileCard(int level, double levelProgress, int points, String rankTitle) {
    final nextLevelPoints = (level + 1) * 100;
    final displayName = _getDisplayName();

    return Column(
      children: [
        ScaleTransition(
          scale: _avatarScale,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [HeritageColors.orange, Color(0xFFE76F51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: HeritageColors.orange.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
              border: Border.all(color: HeritageColors.cream.withValues(alpha: 0.2), width: 2),
            ),
            child: Center(
              child: Text(_selectedAvatarEmoji, style: const TextStyle(fontSize: 50)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          displayName,
          style: GoogleFonts.playfairDisplay(
            color: HeritageColors.cream,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: HeritageColors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: HeritageColors.orange, size: 14),
              const SizedBox(width: 6),
              Text(
                rankTitle.toUpperCase(),
                style: const TextStyle(
                  color: HeritageColors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '"$_customBio"',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Level $level', style: const TextStyle(color: HeritageColors.cream, fontWeight: FontWeight.bold)),
                Text('$points / $nextLevelPoints XP', style: const TextStyle(color: HeritageColors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: levelProgress,
                minHeight: 8,
                color: HeritageColors.orange,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(int points) {
    final rankLabel = _rank <= 0 ? '#1' : '#$_rank';
    return Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.bolt, color: const Color(0xFFF4A261), value: '$points', label: 'TOTAL XP', subtitle: 'Experience')),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(icon: Icons.shield, color: const Color(0xFF52B788), value: '${_userReports.length}', label: 'REPORTS', subtitle: 'Submitted')),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(icon: Icons.emoji_events, color: const Color(0xFFE9C46A), value: rankLabel, label: 'RANK', subtitle: 'Sri Lanka')),
      ],
    );
  }

  Widget _buildGeminiAiCard() {
    final hasKey = AppConfig.effectiveGeminiApiKey.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hasKey ? const Color(0x6652B788) : const Color(0x66E9C46A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasKey ? const Color(0x3352B788) : const Color(0x33E9C46A),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: hasKey ? const Color(0xFF52B788) : const Color(0xFFE9C46A), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Gemini AI Engine', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: hasKey ? const Color(0x3352B788) : const Color(0x33E9C46A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hasKey ? 'CONNECTED' : 'HERITAGE MODE',
                        style: TextStyle(color: hasKey ? const Color(0xFF52B788) : const Color(0xFFE9C46A), fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasKey ? 'Live AI generation active for site research' : 'Tap to configure custom Gemini API key',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A2420),
              foregroundColor: HeritageColors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: const BorderSide(color: Color(0x33E9C46A)),
            ),
            onPressed: _showGeminiConfigDialog,
            child: const Text('Setup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final badges = [
      {'title': 'Fortress Conqueror', 'icon': '🏰', 'desc': 'Explore Galle Dutch Fort & Sigiriya', 'unlocked': true},
      {'title': 'Heritage Guardian', 'icon': '🛡️', 'desc': 'Submit a damage report', 'unlocked': _userReports.isNotEmpty},
      {'title': 'Sacred Pilgrim', 'icon': '🛕', 'desc': 'Visit Tooth Relic & Dambulla', 'unlocked': true},
      {'title': 'Wilderness Tracker', 'icon': '🐘', 'desc': 'Explore Yala or Minneriya', 'unlocked': true},
      {'title': 'Archive Scholar', 'icon': '📜', 'desc': 'Generate custom AI archives', 'unlocked': _completed.isNotEmpty},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Heritage Badges', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${badges.where((b) => b['unlocked'] as bool).length}/${badges.length}', style: const TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 115,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, idx) {
              final b = badges[idx];
              final unlocked = b['unlocked'] as bool;
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF1C1917),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(b['icon'] as String, style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(b['title'] as String, style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(b['desc'] as String, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: unlocked ? const Color(0x3352B788) : Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              unlocked ? 'UNLOCKED (+100 XP)' : 'LOCKED - Complete Heritage Quests',
                              style: TextStyle(color: unlocked ? const Color(0xFF52B788) : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 110,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: unlocked ? HeritageColors.orange.withValues(alpha: 0.5) : Colors.white10),
                    boxShadow: unlocked
                        ? [BoxShadow(color: HeritageColors.orange.withValues(alpha: 0.15), blurRadius: 12, spreadRadius: 1)]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(b['icon'] as String, style: TextStyle(fontSize: 28, color: unlocked ? null : Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        b['title'] as String,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: unlocked ? HeritageColors.cream : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDamageReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Submitted Damage Reports', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/report-damage'),
              child: const Text('+ Report New', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_userReports.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF52B788), size: 24),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No damage reports submitted yet', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('Report cracks or erosion at sites to earn +100 XP', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF52B788), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.of(context).pushNamed('/report-damage'),
                  child: const Text('Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          )
        else
          Column(
            children: _userReports.map((r) => _DamageReportCard(report: r)).toList(),
          ),
      ],
    );
  }

  Widget _buildRecentDiscoveriesSection() {
    final sites = [
      {'name': 'Galle Dutch Fort', 'type': 'UNESCO Fortress', 'img': 'https://images.unsplash.com/photo-1549473889-14f410d83298?q=80&w=300&auto=format&fit=crop'},
      {'name': 'Sigiriya Rock Fortress', 'type': 'Ancient Palace', 'img': 'https://images.unsplash.com/photo-1586224372551-7f91854580bf?q=80&w=300&auto=format&fit=crop'},
      {'name': 'Temple of Tooth Relic', 'type': 'Sacred Temple', 'img': 'https://images.unsplash.com/photo-1625805541012-e8ad54933a2a?q=80&w=300&auto=format&fit=crop'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Heritage Discoveries', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, idx) {
              final site = sites[idx];
              return GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/explore'),
                child: SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(site['img']!, width: 160, height: 95, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 8),
                      Text(site['name']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: HeritageColors.cream, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(site['type']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _QuickAction(icon: Icons.person_outline, color: const Color(0xFF52B788), label: 'Edit Profile', onTap: _showEditProfileDialog)),
              Expanded(child: _QuickAction(icon: Icons.hotel, color: const Color(0xFF9C6ADE), label: 'Hotels & Stays', onTap: () => Navigator.of(context).pushNamed('/hotels'))),
              Expanded(child: _QuickAction(icon: Icons.auto_awesome, color: const Color(0xFFE9C46A), label: 'Shingo AI', onTap: () => Navigator.of(context).pushNamed('/shingo'))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _QuickAction(icon: Icons.shield, color: HeritageColors.orange, label: 'Report Damage', onTap: () => Navigator.of(context).pushNamed('/report-damage'))),
              Expanded(child: _QuickAction(icon: Icons.settings, color: const Color(0xFFF4A261), label: 'Settings', onTap: () => Navigator.of(context).pushNamed('/settings'))),
              Expanded(child: _QuickAction(icon: Icons.bookmark_border, color: const Color(0xFF52B788), label: 'Archives', onTap: () => Navigator.of(context).pushNamed('/archive'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(VoidCallback onLogout) {
    return InkWell(
      onTap: onLogout,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(18),
          color: Colors.redAccent.withValues(alpha: 0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Colors.redAccent, size: 20),
            SizedBox(width: 8),
            Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback action) => InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: HeritageColors.orange, size: 18),
        ),
      );
}

class _DamageReportCard extends StatelessWidget {
  final DamageReport report;

  const _DamageReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final statusColor = report.status == 'resolved'
        ? const Color(0xFF52B788)
        : (report.status == 'in_review' ? const Color(0xFFE9C46A) : HeritageColors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.warning_amber, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.damageType, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(report.location, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
            child: Text(
              report.status.toUpperCase(),
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String subtitle;

  const _StatCard({required this.icon, required this.color, required this.value, required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B18).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: HeritageColors.cream, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
