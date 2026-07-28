// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/profile.dart';
import '../models/user_quest.dart';
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
  int _rank = 0;
  late final AnimationController _avatarController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
  late final Animation<double> _avatarScale = CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut);

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
      if (mounted) {
        setState(() {
          _profile = profile;
          _completed = completed;
          _rank = rank;
        });
      }
    } finally {
      if (mounted) {}
    }
  }

  Future<void> _logout() async {
    if (AppConfig.hasSupabase) await ProfileRepository(Supabase.instance.client).signOut();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  String _getDisplayName() {
    final user = Supabase.instance.client.auth.currentUser;
    final profileName = _profile?.fullName;
    if (profileName != null && profileName.isNotEmpty) return profileName;
    final metaName = user?.userMetadata?['full_name']?.toString();
    if (metaName != null && metaName.isNotEmpty) return metaName;
    final email = user?.email;
    if (email != null && email.isNotEmpty) {
      final local = email.split('@').first;
      if (local.isNotEmpty) return local;
    }
    return 'Explorer';
  }

  @override
  Widget build(BuildContext context) {
    final name = _getDisplayName();
    final points = _profile?.points ?? 0;
    final level = points <= 0 ? 1 : (points ~/ 100).clamp(1, 999);
    final progress = points % 100;
    final levelProgress = progress / 100;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragUpdate: (_) {},
          child: Stack(children: [
            ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 140), children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildLevelCard(level, levelProgress, points),
              const SizedBox(height: 20),
              _buildStatsRow(points),
              const SizedBox(height: 24),
              _buildAchievementsSection(),
              const SizedBox(height: 24),
              _buildRecentActivitySection(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 12),
              _buildDangerZone(_logout),
            ]),
            const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 0)),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')),
      Text('Profile', style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.w600)),
      _round(Icons.bookmark_border, () {}),
    ]);
  }

  Widget _buildLevelCard(int level, double levelProgress, int points) {
    final progress = (levelProgress * 100).toInt();
    final nextLevelPoints = (level + 1) * 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [HeritageColors.orange.withValues(alpha: 0.15), HeritageColors.orange.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Row(children: [
          ScaleTransition(scale: _avatarScale, child: Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: HeritageColors.orange, width: 3)), child: CircleAvatar(radius: 64, backgroundColor: HeritageColors.brown, child: Text(_getDisplayName()[0].toUpperCase(), style: const TextStyle(color: HeritageColors.cream, fontSize: 32, fontWeight: FontWeight.bold))))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_getDisplayName(), style: const TextStyle(color: HeritageColors.cream, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: HeritageColors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Text('LEVEL $level', style: TextStyle(color: HeritageColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1))),
          ])),
          Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle), child: Icon(Icons.emoji_events, color: HeritageColors.orange.withValues(alpha: 0.8), size: 22)),
        ]),
        const SizedBox(height: 16),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: levelProgress, minHeight: 8, color: HeritageColors.orange, backgroundColor: Colors.white.withValues(alpha: 0.1))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$progress% to Level ${level + 1}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
          Text('$points / $nextLevelPoints XP', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  Widget _buildStatsRow(int points) {
    final rankLabel = _rank <= 0 ? '--' : '#$_rank';
    return Row(children: [
      Expanded(child: _StatCard(icon: Icons.star, color: const Color(0xFFF4A261), value: '$points', label: 'POINTS', subtitle: 'Total XP')),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(icon: Icons.location_on, color: const Color(0xFF52B788), value: '${_completed.length}', label: 'PLACES', subtitle: 'Visited')),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(icon: Icons.emoji_events, color: const Color(0xFFE9C46A), value: rankLabel, label: 'RANK', subtitle: 'Global')),
    ]);
  }

  Widget _buildAchievementsSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Achievements', style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.bold)),
        Text('View All', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 12),
      _completed.isEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
              child: Row(children: const [
                Icon(Icons.lock_outline, color: Color(0x66FFFFFF), size: 20),
                SizedBox(width: 12),
                Text('Complete quests to unlock achievements', style: TextStyle(color: Color(0x80FFFFFF), fontSize: 13)),
              ]),
            )
          : SizedBox(height: 100, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _completed.length.clamp(0, 10), separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) => _AchievementBadge(label: 'Quest ${index + 1}'))),
    ]);
  }

  Widget _buildRecentActivitySection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recent Discoveries', style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list, size: 16), label: const Text('Filter', style: TextStyle(fontSize: 12))),
      ]),
      const SizedBox(height: 12),
      _completed.isEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
              child: const Row(children: [
                Icon(Icons.explore_outlined, color: Color(0x66FFFFFF), size: 20),
                SizedBox(width: 12),
                Text('No recent discoveries yet', style: TextStyle(color: Color(0x80FFFFFF), fontSize: 13)),
              ]),
            )
          : SizedBox(height: 140, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _completed.length.clamp(0, 8), separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, index) => _DiscoveryCard(label: 'Quest ${index + 1}', daysAgo: index + 1))),
    ]);
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(children: [
        Row(children: [
          Expanded(child: _QuickAction(icon: Icons.person_outline, color: const Color(0xFF52B788), label: 'Edit Profile', onTap: () => Navigator.of(context).pushNamed('/settings'))),
          Expanded(child: _QuickAction(icon: Icons.map_outlined, color: const Color(0xFF9C6ADE), label: 'My Quests', onTap: () => Navigator.of(context).pushNamed('/quests'))),
          Expanded(child: _QuickAction(icon: Icons.settings_outlined, color: HeritageColors.orange, label: 'Settings', onTap: () => Navigator.of(context).pushNamed('/settings'))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _QuickAction(icon: Icons.help_outline, color: const Color(0xB3FFFFFF), label: 'Help', onTap: () => Navigator.of(context).pushNamed('/settings/help'))),
          Expanded(child: _QuickAction(icon: Icons.history, color: const Color(0xFFF4A261), label: 'History', onTap: () => Navigator.of(context).pushNamed('/archive'))),
          Expanded(child: _QuickAction(icon: Icons.share, color: const Color(0xFF52B788), label: 'Share', onTap: () {})),
        ]),
      ]),
    );
  }

  Widget _buildDangerZone(VoidCallback onLogout) {
    return InkWell(onTap: onLogout, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(border: Border.all(color: const Color(0x33E76F51)), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.logout, color: Color(0xFFE76F51), size: 18), SizedBox(width: 8), Text('Log Out', style: TextStyle(color: Color(0xFFE76F51), fontWeight: FontWeight.w600))])));
  }

  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white.withValues(alpha: 0.08)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 18)));
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF17140F), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 16)),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(color: HeritageColors.cream, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
      ]),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String label;

  const _AchievementBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final emojis = ['🏆', '🌿', '📸', '🗺️', '🦁', '📜', '⛰️', '🌊'];
    final emoji = emojis[label.hashCode % emojis.length];
    return Container(
      width: 72,
      decoration: BoxDecoration(color: const Color(0xFF17140F), borderRadius: BorderRadius.circular(18), border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.15))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: HeritageColors.orange.withValues(alpha: 0.12), shape: BoxShape.circle), child: Text(emoji, style: const TextStyle(fontSize: 20))),
        const SizedBox(height: 8),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  final String label;
  final int daysAgo;

  const _DiscoveryCard({required this.label, required this.daysAgo});

  @override
  Widget build(BuildContext context) {
    final images = [
      'https://images.unsplash.com/photo-1549473889-14f410d83298?q=80&w=300&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1586224372551-7f91854580bf?q=80&w=300&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1625805541012-e8ad54933a2a?q=80&w=300&auto=format&fit=crop',
    ];
    return SizedBox(width: 150, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(images[daysAgo % images.length], width: 150, height: 100, fit: BoxFit.cover)),
      const SizedBox(height: 8),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: HeritageColors.cream, fontSize: 13, fontWeight: FontWeight.w600)),
      Text('$daysAgo days ago', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
    ]));
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
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    ));
  }
}
