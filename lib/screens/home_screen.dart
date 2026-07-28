// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

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
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final rawName = _profile?.fullName.trim();
    final name = rawName == null || rawName.isEmpty ? 'Explorer' : rawName;
    final firstName = name.split(' ').first;
    final points = _profile?.points ?? 0;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 140), children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/profile'),
                child: ClipOval(child: Image.network('https://api.builder.io/api/v1/image/assets/TEMP/8ac6e4f2918cb1ade2b53e903533707e4b93794a?width=88', width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CircleAvatar(backgroundColor: HeritageColors.brown, child: Icon(Icons.person, color: HeritageColors.cream)))),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('EXPLORER', style: TextStyle(color: Color(0x99FEFAE0), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.6)),
                Text('Hello $firstName!', style: const TextStyle(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold, height: 1.55)),
              ]),
              const Spacer(),
              _CircleButton(icon: Icons.verified_user_outlined, onTap: () => Navigator.of(context).pushNamed('/profile')),
            ]),
            const SizedBox(height: 34),
            Text('WELCOME $firstName!', style: const TextStyle(color: Color(0xFF52B788), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text('Protect.\nDiscover.', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 42, fontWeight: FontWeight.w800, height: 1.10, letterSpacing: -1.05)),
            Text('Celebrate.', style: GoogleFonts.playfairDisplay(color: HeritageColors.orange, fontSize: 42, fontStyle: FontStyle.italic, height: 1.10, letterSpacing: -1.05)),
            const SizedBox(height: 24),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _StatPill(icon: Icons.location_on, color: const Color(0xFF52B788), text: '$_visited Places Visited'),
              _StatPill(icon: Icons.star, color: const Color(0xFFE9C46A), text: '$points Points'),
              _StatPill(icon: Icons.emoji_events, color: const Color(0xFF52B788), text: _rank == 0 ? 'Rank #-' : 'Rank #$_rank'),
            ]),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/report-damage'),
              child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: HeritageColors.orange.withValues(alpha:0.10), border: Border.all(color: HeritageColors.orange.withValues(alpha:0.20)), borderRadius: BorderRadius.circular(16)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('⚠️', style: TextStyle(fontSize: 20)), const SizedBox(width: 12), const Expanded(child: Text('Community Report: Damage detected at Galle Fort. Tap to verify.', style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.w500, height: 1.625))), const Icon(Icons.chevron_right, color: Color(0x99F4A261))])),
            ),
            const SizedBox(height: 24),
            _HomeCard(icon: Icons.report_problem_outlined, title: 'Report Damages', subtitle: 'Help us preserve our heritage by reporting any issues you see.', color: HeritageColors.orange, onTap: () => Navigator.of(context).pushNamed('/report-damage')),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _GridCard(emoji: '📸', title: 'Scanner', subtitle: 'Identify Heritage and Wildlife', borderColor: const Color(0xFF52B788), onTap: () => Navigator.of(context).pushNamed('/scanner'))),
              const SizedBox(width: 12),
              Expanded(child: Column(children: [
                _SmallGridCard(emoji: '🗺️', title: 'Map', borderColor: const Color(0xFF2D6A4F), onTap: () => Navigator.of(context).pushNamed('/explore')),
                const SizedBox(height: 12),
                _SmallGridCard(emoji: '📖', title: 'Archive', borderColor: HeritageColors.orange, onTap: () => Navigator.of(context).pushNamed('/archive')),
              ])),
            ]),
            const SizedBox(height: 16),
            _BannerCard(emoji: '✨', title: 'Shingo AI', subtitle: 'Your personal AI guide to Sri Lankan heritage. Ask anything about history, culture, or sites.', borderColor: const Color(0xFFE9C46A), bgColor: const Color(0xFFE9C46A), onTap: () => Navigator.of(context).pushNamed('/archive/shingo')),
            const SizedBox(height: 16),
            _BannerCard(emoji: '🎮', title: 'Quests', subtitle: 'Complete challenges to earn points and compete with others on the leaderboard.', borderColor: const Color(0xFFB752B7), bgColor: const Color(0xFFB752B7), onTap: () => Navigator.of(context).pushNamed('/quests')),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Nearby Heritage', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 28, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/explore'),
                child: const Text('See All', style: TextStyle(color: Color(0xFF52B788), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _NearbyCard(emoji: '🏰', name: 'Galle Fort', distance: '1.2 km away', onTap: () => Navigator.of(context).pushNamed('/explore'))),
              const SizedBox(width: 12),
              Expanded(child: _NearbyCard(emoji: '🛕', name: 'Yatagala Temple', distance: '3.5 km away', onTap: () => Navigator.of(context).pushNamed('/explore'))),
            ]),
          ]),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 0)),
        ]),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget { const _CircleButton({required this.icon, required this.onTap}); final IconData icon; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: const Color(0x2652B788)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.cream, size: 20))); }
class _StatPill extends StatelessWidget { const _StatPill({required this.icon, required this.color, required this.text}); final IconData icon; final Color color; final String text; @override Widget build(BuildContext context) => Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: const Color(0x3352B788)), borderRadius: BorderRadius.circular(30)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 14), const SizedBox(width: 8), Text(text, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w500))])); }
class _HomeCard extends StatelessWidget { const _HomeCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap}); final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(28), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: color.withValues(alpha:0.20)), borderRadius: BorderRadius.circular(28)), child: Row(children: [Icon(icon, color: color, size: 30), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Color(0x99FEFAE0), fontSize: 12))])), Container(width: 28, height: 28, decoration: BoxDecoration(color: color.withValues(alpha:0.20), shape: BoxShape.circle), child: Icon(Icons.arrow_forward_ios, color: color, size: 14))]))); }

class _GridCard extends StatelessWidget { const _GridCard({required this.emoji, required this.title, required this.subtitle, required this.borderColor, required this.onTap}); final String emoji; final String title; final String subtitle; final Color borderColor; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(32), child: Container(height: 220, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: borderColor.withValues(alpha:0.20)), borderRadius: BorderRadius.circular(32)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(emoji, style: const TextStyle(fontSize: 40)), const Spacer(), Text(title, style: const TextStyle(color: HeritageColors.cream, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: Color(0x99FEFAE0), fontSize: 12))]))); }

class _SmallGridCard extends StatelessWidget { const _SmallGridCard({required this.emoji, required this.title, required this.borderColor, required this.onTap}); final String emoji; final String title; final Color borderColor; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(28), child: Container(height: 94, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: borderColor.withValues(alpha:0.30)), borderRadius: BorderRadius.circular(28)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(emoji, style: const TextStyle(fontSize: 24)), Container(width: 24, height: 24, decoration: BoxDecoration(color: borderColor.withValues(alpha:0.20), shape: BoxShape.circle), child: Icon(Icons.arrow_forward_ios, color: borderColor, size: 10))]), Text(title, style: const TextStyle(color: HeritageColors.cream, fontSize: 16, fontWeight: FontWeight.bold))]))); }

class _BannerCard extends StatelessWidget { const _BannerCard({required this.emoji, required this.title, required this.subtitle, required this.borderColor, required this.bgColor, required this.onTap}); final String emoji; final String title; final String subtitle; final Color borderColor; final Color bgColor; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(28), child: Container(constraints: const BoxConstraints(minHeight: 120), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: bgColor.withValues(alpha:0.05), border: Border.all(color: borderColor.withValues(alpha:0.30)), borderRadius: BorderRadius.circular(28)), child: Row(children: [Container(width: 60, height: 60, decoration: BoxDecoration(color: bgColor.withValues(alpha:0.20), shape: BoxShape.circle), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28)))), const SizedBox(width: 20), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: HeritageColors.cream, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Color(0xB3FEFAE0), fontSize: 13, height: 1.5))]))]))); }

class _NearbyCard extends StatelessWidget { const _NearbyCard({required this.emoji, required this.name, required this.distance, this.onTap}); final String emoji; final String name; final String distance; final VoidCallback? onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: const Color(0x2652B788)), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0x0DFEFAE0), shape: BoxShape.circle), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32)))), const SizedBox(height: 16), Text(name, style: const TextStyle(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(distance, style: const TextStyle(color: Color(0x80FEFAE0), fontSize: 13))]))); }

