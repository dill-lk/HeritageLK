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

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? _profile;
  List<UserQuest> _completed = const [];
  int _rank = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!AppConfig.hasSupabase) return;
    setState(() => _loading = true);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    if (AppConfig.hasSupabase) await ProfileRepository(Supabase.instance.client).signOut();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = AppConfig.hasSupabase ? Supabase.instance.client.auth.currentUser : null;
    final emailName = user?.email?.split('@').first;
    final name = _profile?.fullName ?? user?.userMetadata?['full_name']?.toString() ?? emailName ?? 'Explorer';
    final points = _profile?.points ?? 0;
    final level = points <= 0 ? 1 : (points ~/ 100).clamp(1, 999);
    final progress = points % 100;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 140), children: [
            _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')),
            const SizedBox(height: 32),
            Center(child: Column(children: [
              Stack(children: [
                ClipOval(child: Image.network('https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=300&auto=format&fit=crop', width: 128, height: 128, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CircleAvatar(radius: 64, backgroundColor: HeritageColors.brown, child: Icon(Icons.person, color: HeritageColors.cream, size: 48)))),
                Positioned(right: 4, bottom: 4, child: Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF52B788), border: Border.all(color: HeritageColors.background, width: 3), shape: BoxShape.circle), child: const Icon(Icons.edit, color: HeritageColors.background, size: 15))),
              ]),
              const SizedBox(height: 16),
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('LEVEL $level - MASTER', style: const TextStyle(color: Color(0xFF52B788), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ])),
            if (_loading) const Padding(padding: EdgeInsets.only(top: 24), child: LinearProgressIndicator(color: Color(0xFF52B788), backgroundColor: Color(0x1AFFFFFF))),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Level $level', style: const TextStyle(color: Color(0xFF52B788), fontSize: 12, fontWeight: FontWeight.bold)),
              Text('$progress% to Level ${level + 1}', style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress / 100, minHeight: 8, color: const Color(0xFF52B788), backgroundColor: const Color(0xFF29261E))),
            const SizedBox(height: 28),
            Row(children: [
              _stat(Icons.star, const Color(0xFFF4A261), '$points', 'POINTS'),
              const SizedBox(width: 12),
              _stat(Icons.location_on, const Color(0xFF52B788), '${_completed.length}', 'PLACES'),
              const SizedBox(width: 12),
              _stat(Icons.emoji_events, const Color(0xFF52B788), _rank == 0 ? '#-' : '#$_rank', 'RANK'),
            ]),
            const SizedBox(height: 36),
            _sectionHeader('Achievements', 'View All'),
            const SizedBox(height: 12),
            SizedBox(height: 102, child: _completed.isEmpty ? const Align(alignment: Alignment.centerLeft, child: Text('Complete quests to unlock achievements!', style: TextStyle(color: Color(0x80FFFFFF), fontSize: 14))) : ListView.separated(scrollDirection: Axis.horizontal, itemCount: _completed.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, index) => _achievement(_completed[index]))),
            const SizedBox(height: 28),
            _sectionHeader('Recent Discoveries', 'History'),
            const SizedBox(height: 12),
            SizedBox(height: 150, child: _completed.isEmpty ? const Align(alignment: Alignment.centerLeft, child: Text('No recent discoveries.', style: TextStyle(color: Color(0x80FFFFFF), fontSize: 14))) : ListView.separated(scrollDirection: Axis.horizontal, itemCount: _completed.length, separatorBuilder: (_, __) => const SizedBox(width: 14), itemBuilder: (_, index) => _discovery(_completed[index], index))),
            const SizedBox(height: 20),
            _action(Icons.person, const Color(0xFF52B788), 'Edit Profile', () => Navigator.of(context).pushNamed('/settings')),
            _action(Icons.map, const Color(0xFF9C6ADE), 'My Quests', () => Navigator.of(context).pushNamed('/quests')),
            _action(Icons.settings, HeritageColors.orange, 'Settings', () => Navigator.of(context).pushNamed('/settings')),
            _action(Icons.help_outline, const Color(0xB3FFFFFF), 'Help & Support', () => Navigator.of(context).pushNamed('/settings/help')),
            const SizedBox(height: 18),
            InkWell(onTap: _logout, borderRadius: BorderRadius.circular(24), child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(border: Border.all(color: const Color(0x33E76F51)), borderRadius: BorderRadius.circular(24)), child: const Center(child: Text('Log Out', style: TextStyle(color: Color(0xFFE76F51), fontWeight: FontWeight.bold))))),
          ]),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 0)),
        ]),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF201D19), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xB3FFFFFF), size: 20)));
  Widget _stat(IconData icon, Color color, String value, String label) => Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF17140F), border: Border.all(color: Colors.white.withValues(opacity:0.05)), borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon(icon, color: color), const SizedBox(height: 8), Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))])));
  Widget _sectionHeader(String title, String action) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), Text(action, style: const TextStyle(color: Color(0xFF52B788), fontSize: 12, fontWeight: FontWeight.bold))]);
  Widget _achievement(UserQuest quest) => Container(width: 80, decoration: BoxDecoration(color: const Color(0xFF17140F), border: Border.all(color: Colors.white.withValues(opacity:0.05)), borderRadius: BorderRadius.circular(24)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircleAvatar(radius: 16, backgroundColor: Color(0x1AFFFFFF), child: Text('🌟', style: TextStyle(fontSize: 16))), const SizedBox(height: 10), Text(quest.questId.split('-').first, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 10))]));
  Widget _discovery(UserQuest quest, int index) { final images = ['https://images.unsplash.com/photo-1549473889-14f410d83298?q=80&w=300&auto=format&fit=crop', 'https://images.unsplash.com/photo-1586224372551-7f91854580bf?q=80&w=300&auto=format&fit=crop', 'https://images.unsplash.com/photo-1625805541012-e8ad54933a2a?q=80&w=300&auto=format&fit=crop']; return SizedBox(width: 140, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(images[index % images.length], width: 140, height: 100, fit: BoxFit.cover)), const SizedBox(height: 8), Text(quest.questId.replaceAll('-', ' '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), const Text('Recently', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 10))])); }
  Widget _action(IconData icon, Color color, String title, VoidCallback action) => Padding(padding: const EdgeInsets.only(bottom: 12), child: InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF17140F), border: Border.all(color: Colors.white.withValues(opacity:0.05)), borderRadius: BorderRadius.circular(24)), child: Row(children: [CircleAvatar(radius: 20, backgroundColor: color.withValues(opacity:0.20), child: Icon(icon, color: color, size: 18)), const SizedBox(width: 16), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const Icon(Icons.chevron_right, color: Color(0x4DFFFFFF))]))));
}
