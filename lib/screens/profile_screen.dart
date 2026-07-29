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

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  Profile? _profile;
  List<UserQuest> _completed = const [];
  List<DamageReport> _userReports = const [];
  List<Profile> _leaderboard = const [];
  int _rank = 0;
  String _selectedAvatarEmoji = '🦁';
  String _customBio = 'Passionate explorer preserving Sri Lanka\'s ancient wonders.';

  late final AnimationController _avatarController = AnimationController(
    duration: const Duration(milliseconds: 900),
    vsync: this,
  );
  late final Animation<double> _avatarScale =
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut);

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
      final rank =
          profile == null ? 0 : await profileRepo.rankForPoints(profile.points);
      List<DamageReport> reports = [];
      List<Profile> leaders = [];
      try {
        reports = await DamageReportRepository(client).list();
        leaders = await profileRepo.leaderboard(limit: 5);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _profile = profile;
          _completed = completed;
          _userReports = reports;
          _leaderboard = leaders;
          _rank = rank;
        });
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    if (AppConfig.hasSupabase) {
      await ProfileRepository(Supabase.instance.client).signOut();
    }
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  String _getDisplayName() {
    final user =
        AppConfig.hasSupabase ? Supabase.instance.client.auth.currentUser : null;
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

  // Preservation score 0-100 based on user activity
  int _getPreservationScore() {
    int score = 0;
    final points = _profile?.points ?? 0;
    score += (points / 20).clamp(0, 40).toInt();
    score += (_userReports.length * 10).clamp(0, 30).toInt();
    score += (_completed.length * 5).clamp(0, 20).toInt();
    score += 10; // base
    return score.clamp(0, 100);
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(children: [
            const Icon(Icons.edit_note, color: HeritageColors.orange),
            const SizedBox(width: 10),
            Text('Edit Explorer Profile',
                style: GoogleFonts.playfairDisplay(
                    color: HeritageColors.cream, fontSize: 20)),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose Avatar Badge',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _culturalAvatars.map((av) {
                    final selected = av['emoji'] == tempEmoji;
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => tempEmoji = av['emoji']!),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected
                              ? HeritageColors.orange.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                              color: selected
                                  ? HeritageColors.orange
                                  : Colors.white10,
                              width: selected ? 2 : 1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(av['emoji']!,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Display Name',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: HeritageColors.orange)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Explorer Bio / Motto',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: bioController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: HeritageColors.orange)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HeritageColors.orange,
                foregroundColor: HeritageColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
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
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated! ✨')));
              },
              child: const Text('Save Profile',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = _profile?.points ?? 150;
    final level = points <= 0 ? 1 : (points ~/ 100).clamp(1, 999);
    final levelProgress = (points % 100) / 100.0;
    final rankTitle = _getRankTitle(points);
    final preservationScore = _getPreservationScore();

    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Top gradient glow
            Positioned(
              top: 0, left: 0, right: 0, height: 320,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      HeritageColors.orange.withValues(alpha: 0.12),
                      HeritageColors.background,
                    ],
                  ),
                ),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
                _buildHeroCard(level, levelProgress, points, rankTitle),
                const SizedBox(height: 24),
                _buildStatsRow(points),
                const SizedBox(height: 24),
                _buildPreservationScore(preservationScore),
                const SizedBox(height: 24),
                _buildImpactSection(),
                const SizedBox(height: 24),
                _buildLeaderboard(),
                const SizedBox(height: 24),
                _buildAchievementsSection(),
                const SizedBox(height: 24),
                _buildDamageReportsSection(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: HeritageBottomNav(currentIndex: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _round(Icons.arrow_back,
            () => Navigator.of(context).pushReplacementNamed('/home')),
        Text(
          'My Profile',
          style: GoogleFonts.playfairDisplay(
              color: HeritageColors.cream,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        _round(Icons.edit, _showEditProfileDialog),
      ],
    );
  }

  Widget _buildHeroCard(
      int level, double levelProgress, int points, String rankTitle) {
    final displayName = _getDisplayName();
    final nextLevelPoints = (level + 1) * 100;
    final userEmail = AppConfig.hasSupabase
        ? (Supabase.instance.client.auth.currentUser?.email ?? '')
        : '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F15), Color(0xFF1A1410)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: HeritageColors.orange.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: HeritageColors.orange.withValues(alpha: 0.08),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _avatarScale,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [HeritageColors.orange, Color(0xFFE76F51)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: HeritageColors.orange.withValues(alpha: 0.45),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                    border: Border.all(
                        color: HeritageColors.cream.withValues(alpha: 0.15),
                        width: 2),
                  ),
                  child: Center(
                    child: Text(_selectedAvatarEmoji,
                        style: const TextStyle(fontSize: 44)),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.playfairDisplay(
                          color: HeritageColors.cream,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: HeritageColors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                HeritageColors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: HeritageColors.orange, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            rankTitle.toUpperCase(),
                            style: const TextStyle(
                              color: HeritageColors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"$_customBio"',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LEVEL $level',
                  style: const TextStyle(
                      color: HeritageColors.cream,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              Text('$points / $nextLevelPoints XP',
                  style: const TextStyle(
                      color: HeritageColors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: levelProgress,
              minHeight: 7,
              color: HeritageColors.orange,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int points) {
    final rankLabel = _rank <= 0 ? '#1' : '#$_rank';
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                icon: Icons.bolt_rounded,
                color: const Color(0xFFF4A261),
                value: '$points',
                label: 'TOTAL XP')),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                icon: Icons.shield_rounded,
                color: const Color(0xFF52B788),
                value: '${_userReports.length}',
                label: 'REPORTS')),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                icon: Icons.emoji_events_rounded,
                color: const Color(0xFFE9C46A),
                value: rankLabel,
                label: 'RANK')),
      ],
    );
  }

  Widget _buildPreservationScore(int score) {
    final color = score >= 70
        ? const Color(0xFF52B788)
        : score >= 40
            ? HeritageColors.orange
            : const Color(0xFFE76F51);
    final label = score >= 70
        ? 'Excellent Custodian'
        : score >= 40
            ? 'Active Preserver'
            : 'Begin Your Journey';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1714),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 20,
              spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('PRESERVATION SCORE',
                        style: TextStyle(
                            color: HeritageColors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                  ]),
                  const SizedBox(height: 6),
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                '$score',
                style: TextStyle(
                    color: color,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100.0,
              minHeight: 6,
              color: color,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _scoreContrib(Icons.flash_on_rounded, '${(_profile?.points ?? 0)} XP earned', const Color(0xFFF4A261)),
              const SizedBox(width: 16),
              _scoreContrib(Icons.warning_amber_rounded, '${_userReports.length} sites reported', const Color(0xFF52B788)),
              const SizedBox(width: 16),
              _scoreContrib(Icons.check_circle_outline_rounded, '${_completed.length} completed', const Color(0xFFE9C46A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreContrib(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildImpactSection() {
    final sitesScanned = (_completed.length + 2).clamp(1, 999);
    final reportsCount = _userReports.length;
    final totalUsers = 1247;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Heritage Impact',
            style: GoogleFonts.playfairDisplay(
                color: HeritageColors.cream,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1714),
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              _impactRow(
                emoji: '🏛️',
                title: 'Sites Discovered',
                value: '$sitesScanned sites',
                subtitle: 'Explored via scanner & map',
                color: HeritageColors.orange,
              ),
              _impactDivider(),
              _impactRow(
                emoji: '🛡️',
                title: 'Sites Protected',
                value: '$reportsCount reports',
                subtitle: 'Damage flagged for authorities',
                color: const Color(0xFF52B788),
              ),
              _impactDivider(),
              _impactRow(
                emoji: '🌍',
                title: 'Community Standing',
                value: '$totalUsers explorers',
                subtitle: _rank <= 0
                    ? 'You\'re in the top tier!'
                    : 'Ranked #$_rank in Sri Lanka',
                color: const Color(0xFFE9C46A),
              ),
              _impactDivider(),
              _impactRow(
                emoji: '💡',
                title: 'Guide Queries',
                value: '${(_completed.length * 3 + 5)} queries',
                subtitle: 'Heritage insights generated',
                color: const Color(0xFF9C6ADE),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _impactRow({
    required String emoji,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _impactDivider() =>
      Container(height: 1, color: Colors.white.withValues(alpha: 0.05));

  Widget _buildLeaderboard() {
    final leaders = _leaderboard.isNotEmpty
        ? _leaderboard
        : [
            Profile(id: '1', fullName: 'Sanul Randisa', points: 15200),
            Profile(id: '2', fullName: 'Jinuk Chanthusa', points: 11800),
            Profile(id: '3', fullName: 'Disara Bimsilu', points: 10900),
            Profile(id: '4', fullName: 'Kavindu Perera', points: 8750),
            Profile(id: '5', fullName: 'Nimasha Silva', points: 7200),
          ];

    final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
    final myName = _getDisplayName();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Community Leaderboard',
                style: GoogleFonts.playfairDisplay(
                    color: HeritageColors.cream,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE9C46A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFE9C46A).withValues(alpha: 0.3)),
              ),
              child: const Text('LIVE',
                  style: TextStyle(
                      color: Color(0xFFE9C46A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1714),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: [
              ...List.generate(leaders.length, (i) {
                final leader = leaders[i];
                final isMe = leader.fullName == myName;
                final medal = i < medals.length ? medals[i] : '${i + 1}';
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isMe
                            ? HeritageColors.orange.withValues(alpha: 0.07)
                            : Colors.transparent,
                        borderRadius: i == 0
                            ? const BorderRadius.vertical(
                                top: Radius.circular(24))
                            : i == leaders.length - 1
                                ? const BorderRadius.vertical(
                                    bottom: Radius.circular(24))
                                : BorderRadius.zero,
                      ),
                      child: Row(
                        children: [
                          Text(medal,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isMe
                                  ? HeritageColors.orange
                                      .withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.06),
                              border: Border.all(
                                  color: isMe
                                      ? HeritageColors.orange
                                          .withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Center(
                                child: Text(
                              leader.fullName.isNotEmpty
                                  ? leader.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  color: isMe
                                      ? HeritageColors.orange
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leader.fullName,
                                  style: TextStyle(
                                      color: isMe
                                          ? HeritageColors.orange
                                          : HeritageColors.cream,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (isMe)
                                  const Text('← You',
                                      style: TextStyle(
                                          color: HeritageColors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Text(
                            '${leader.points} XP',
                            style: TextStyle(
                                color: i == 0
                                    ? const Color(0xFFE9C46A)
                                    : Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (i < leaders.length - 1)
                      Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.04)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    final badges = [
      {
        'title': 'Fortress Conqueror',
        'icon': '🏰',
        'desc': 'Explore Galle Dutch Fort & Sigiriya',
        'unlocked': true
      },
      {
        'title': 'Heritage Guardian',
        'icon': '🛡️',
        'desc': 'Submit a damage report',
        'unlocked': _userReports.isNotEmpty
      },
      {
        'title': 'Sacred Pilgrim',
        'icon': '🛕',
        'desc': 'Visit Temple of Tooth Relic',
        'unlocked': true
      },
      {
        'title': 'Wilderness Tracker',
        'icon': '🐘',
        'desc': 'Explore Yala or Minneriya',
        'unlocked': true
      },
      {
        'title': 'Archive Scholar',
        'icon': '📜',
        'desc': 'Generate heritage archives',
        'unlocked': _completed.isNotEmpty
      },
      {
        'title': 'Shingo Seeker',
        'icon': '📜',
        'desc': 'Consult Shingo Guide 10+ times',
        'unlocked': _completed.length >= 3
      },
    ];

    final unlockedCount = badges.where((b) => b['unlocked'] as bool).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Heritage Badges',
                style: GoogleFonts.playfairDisplay(
                    color: HeritageColors.cream,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('$unlockedCount/${badges.length} unlocked',
                style: const TextStyle(
                    color: HeritageColors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, idx) {
              final b = badges[idx];
              final unlocked = b['unlocked'] as bool;
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF1C1917),
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(b['icon'] as String,
                              style: const TextStyle(fontSize: 52)),
                          const SizedBox(height: 14),
                          Text(b['title'] as String,
                              style: GoogleFonts.playfairDisplay(
                                  color: HeritageColors.cream,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(b['desc'] as String,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 14)),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: unlocked
                                  ? const Color(0x3352B788)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              unlocked
                                  ? '✅ UNLOCKED — +100 XP earned'
                                  : '🔒 Complete more heritage activities',
                              style: TextStyle(
                                  color: unlocked
                                      ? const Color(0xFF52B788)
                                      : Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 108,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1714),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: unlocked
                            ? HeritageColors.orange.withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: 0.06)),
                    boxShadow: unlocked
                        ? [
                            BoxShadow(
                                color: HeritageColors.orange
                                    .withValues(alpha: 0.12),
                                blurRadius: 14,
                                spreadRadius: 1)
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ColorFiltered(
                        colorFilter: unlocked
                            ? const ColorFilter.mode(
                                Colors.transparent, BlendMode.saturation)
                            : const ColorFilter.matrix([
                                0.2, 0.2, 0.2, 0, 0,
                                0.2, 0.2, 0.2, 0, 0,
                                0.2, 0.2, 0.2, 0, 0,
                                0, 0, 0, 1, 0,
                              ]),
                        child: Text(b['icon'] as String,
                            style: const TextStyle(fontSize: 30)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b['title'] as String,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: unlocked
                                ? HeritageColors.cream
                                : Colors.white30,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
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
            Text('Submitted Damage Reports',
                style: GoogleFonts.playfairDisplay(
                    color: HeritageColors.cream,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/report-damage'),
              child: const Text('+ Report New',
                  style: TextStyle(
                      color: HeritageColors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_userReports.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1714),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF52B788).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: Color(0xFF52B788), size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No damage reports yet',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text('Flag erosion or vandalism to earn +100 XP',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52B788),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/report-damage'),
                  child: const Text('Report',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          )
        else
          Column(
              children:
                  _userReports.map((r) => _DamageReportCard(report: r)).toList()),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1714),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _QuickAction(
                      icon: Icons.person_outline_rounded,
                      color: const Color(0xFF52B788),
                      label: 'Edit Profile',
                      onTap: _showEditProfileDialog)),
              Expanded(
                  child: _QuickAction(
                      icon: Icons.hotel_rounded,
                      color: const Color(0xFF9C6ADE),
                      label: 'Hotels',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/hotels'))),
              Expanded(
                  child: _QuickAction(
                      icon: Icons.chat_bubble_outline_rounded,
                      color: const Color(0xFFE9C46A),
                      label: 'Shingo AI',
                      onTap: () => Navigator.of(context)
                          .pushNamed('/archive/shingo'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _QuickAction(
                      icon: Icons.warning_amber_rounded,
                      color: HeritageColors.orange,
                      label: 'Report',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/report-damage'))),
              Expanded(
                  child: _QuickAction(
                      icon: Icons.settings_rounded,
                      color: const Color(0xFFF4A261),
                      label: 'Settings',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/settings'))),
              Expanded(
                  child: _QuickAction(
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFF52B788),
                      label: 'Archives',
                      onTap: () =>
                          Navigator.of(context).pushNamed('/archive'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _logout,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE76F51).withValues(alpha: 0.45)),
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFFE76F51).withValues(alpha: 0.08),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE76F51), size: 20),
            SizedBox(width: 10),
            Text('Log Out',
                style: TextStyle(
                    color: Color(0xFFE76F51),
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
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

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _DamageReportCard extends StatelessWidget {
  final DamageReport report;
  const _DamageReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final statusColor = report.status == 'resolved'
        ? const Color(0xFF52B788)
        : report.status == 'in_review'
            ? const Color(0xFFE9C46A)
            : HeritageColors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1714),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child:
                Icon(Icons.warning_amber_rounded, color: statusColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.damageType,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(report.location,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12)),
            child: Text(report.status.toUpperCase(),
                style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
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

  const _StatCard(
      {required this.icon,
      required this.color,
      required this.value,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1714),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 12,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: HeritageColors.cream,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
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

  const _QuickAction(
      {required this.icon,
      required this.color,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: color.withValues(alpha: 0.2))),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: HeritageColors.cream.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
