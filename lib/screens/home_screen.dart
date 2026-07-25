import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/profile.dart';
import '../services/profile_repository.dart';
import '../services/quest_repository.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Profile? _profile;
  int _rank = 0;
  int _visited = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (!AppConfig.hasSupabase) return;
    try {
      final client = Supabase.instance.client;
      final profileRepo = ProfileRepository(client);
      final profile = await profileRepo.currentProfile();
      final completed = await QuestRepository(client).completedQuests();
      final rank = profile == null ? 0 : await profileRepo.rankForPoints(profile.points);
      if (mounted) {
        setState(() {
          _profile = profile;
          _visited = completed.length;
          _rank = rank;
        });
      }
    } catch (_) {
      // The dashboard keeps the exact offline shell when Supabase is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?.fullName.trim().isEmpty ?? true ? 'Explorer' : _profile!.fullName.trim();
    final points = _profile?.points ?? 0;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 130), children: [
            Row(children: [
              ClipOval(child: Image.network('https://api.builder.io/api/v1/image/assets/TEMP/8ac6e4f2918cb1ade2b53e903533707e4b93794a?width=88', width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CircleAvatar(backgroundColor: HeritageColors.brown, child: Icon(Icons.person, color: HeritageColors.cream)))),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('EXPLORER', style: TextStyle(color: Color(0x99FEFAE0), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.6)), Text('Hello $name!', style: const TextStyle(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold, height: 1.55))]),
              const Spacer(),
              _CircleButton(icon: Icons.verified_user_outlined, onTap: () => Navigator.of(context).pushNamed('/profile')),
            ]),
            const SizedBox(height: 34),
            const Text('WELCOME EXPLORER!', style: TextStyle(color: Color(0xFF52B788), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text('Protect.\nDiscover.', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 42, fontWeight: FontWeight.w800, height: 1.10, letterSpacing: -1.05)),
            Text('Celebrate.', style: GoogleFonts.playfairDisplay(color: HeritageColors.orange, fontSize: 42, fontStyle: FontStyle.italic, height: 1.10, letterSpacing: -1.05)),
            const SizedBox(height: 24),
            Wrap(spacing: 12, runSpacing: 12, children: [_StatPill(icon: Icons.location_on, color: const Color(0xFF52B788), text: '$_visited Places Visited'), _StatPill(icon: Icons.star, color: const Color(0xFFE9C46A), text: '$points Points'), _StatPill(icon: Icons.emoji_events, color: const Color(0xFF52B788), text: _rank == 0 ? 'Rank #-' : 'Rank #$_rank')]),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: HeritageColors.orange.withOpacity(0.10), border: Border.all(color: HeritageColors.orange.withOpacity(0.20)), borderRadius: BorderRadius.circular(16)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('⚠️', style: TextStyle(fontSize: 20)), const SizedBox(width: 12), const Expanded(child: Text('Community Report: Damage detected at Galle Fort. Tap to verify.', style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.w500, height: 1.625))), const Icon(Icons.chevron_right, color: Color(0x99F4A261))])),
            const SizedBox(height: 24),
            _HomeCard(icon: Icons.report_problem_outlined, title: 'Report Damages', subtitle: 'Help protect our shared heritage', color: HeritageColors.orange, onTap: () => Navigator.of(context).pushNamed('/report-damage')),
            const SizedBox(height: 16),
            _HomeCard(icon: Icons.auto_awesome, title: 'Discover with Shingo', subtitle: 'Ask anything about Sri Lanka\'s history', color: const Color(0xFFE9C46A), onTap: () => Navigator.of(context).pushNamed('/archive/shingo')),
            const SizedBox(height: 16),
            _HomeCard(icon: Icons.menu_book_outlined, title: 'Browse the Archive', subtitle: 'Explore stories from our island', color: const Color(0xFF52B788), onTap: () => Navigator.of(context).pushNamed('/archive')),
          ]),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 0)),
        ]),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget { const _CircleButton({required this.icon, required this.onTap}); final IconData icon; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: const Color(0x2652B788)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.cream, size: 20))); }
class _StatPill extends StatelessWidget { const _StatPill({required this.icon, required this.color, required this.text}); final IconData icon; final Color color; final String text; @override Widget build(BuildContext context) => Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: const Color(0x3352B788)), borderRadius: BorderRadius.circular(30)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 14), const SizedBox(width: 8), Text(text, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w500))])); }
class _HomeCard extends StatelessWidget { const _HomeCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap}); final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.08)), borderRadius: BorderRadius.circular(20)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: HeritageColors.cream, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Color(0x99FEFAE0), fontSize: 13))])), Icon(Icons.arrow_forward, color: color, size: 18)]))); }
