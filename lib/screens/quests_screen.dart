import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/profile.dart';
import '../models/quest.dart';
import '../services/profile_repository.dart';
import '../services/quest_repository.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  final _fallbackQuests = const [
    Quest(id: 'visit-galle-dutch-fort', title: 'Visit Galle Dutch Fort', description: 'Explore a living monument to history.', points: 100),
    Quest(id: 'discover-an-ancient-story', title: 'Discover an Ancient Story', description: 'Read an archive record and learn something new.', points: 50),
    Quest(id: 'protect-our-heritage', title: 'Protect Our Heritage', description: 'Submit a verified damage report.', points: 100),
  ];
  List<Quest> _quests = const [];
  List<Profile> _leaders = const [];
  Set<String> _completed = const {'visit-galle-dutch-fort'};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _quests = _fallbackQuests;
    _leaders = const [Profile(id: '1', fullName: 'Disara Bimsilu', points: 300), Profile(id: '2', fullName: 'Heritage Explorer', points: 220), Profile(id: '3', fullName: 'Island Curator', points: 140)];
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    if (!AppConfig.hasSupabase) return;
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final questRepo = QuestRepository(client);
      final quests = await questRepo.listQuests();
      final completed = await questRepo.completedQuests();
      final leaders = await ProfileRepository(client).leaderboard();
      if (mounted) {
        setState(() {
          if (quests.isNotEmpty) _quests = quests;
          _completed = completed.map((quest) => quest.questId).toSet();
          if (leaders.isNotEmpty) _leaders = leaders;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _complete(Quest quest) async {
    if (_completed.contains(quest.id)) return;
    if (!AppConfig.hasSupabase) {
      setState(() => _completed = {..._completed, quest.id});
      return;
    }
    try {
      await QuestRepository(Supabase.instance.client).completeQuest(quest.id);
      if (mounted) {
        setState(() => _completed = {..._completed, quest.id});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${quest.points} points earned.')));
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quest update failed. $error')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Stack(children: [ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 130), children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')), const Text('Quests', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 22)), _round(Icons.leaderboard_outlined, () {})]), const SizedBox(height: 28), const Text('YOUR JOURNEY', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)), const SizedBox(height: 8), const Text('Preserve. Explore. Earn.', style: TextStyle(color: HeritageColors.cream, fontSize: 28, fontWeight: FontWeight.bold)), if (_loading) const Padding(padding: EdgeInsets.only(top: 20), child: LinearProgressIndicator(color: HeritageColors.orange, backgroundColor: Color(0x1AFFFFFF))), const SizedBox(height: 24), ..._quests.map((quest) => _quest(quest, _completed.contains(quest.id))), const SizedBox(height: 28), const Text('LEADERBOARD', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)), const SizedBox(height: 12), ..._leaders.asMap().entries.map(_leaderTile)],), const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 3))])));
  Widget _quest(Quest quest, bool complete) => InkWell(onTap: () => _complete(quest), borderRadius: BorderRadius.circular(20), child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: complete ? const Color(0x4D52B788) : Colors.white.withOpacity(0.07)), borderRadius: BorderRadius.circular(20)), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: (complete ? const Color(0xFF52B788) : HeritageColors.orange).withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(_iconFor(quest.title), color: complete ? const Color(0xFF52B788) : HeritageColors.orange)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(quest.title, style: const TextStyle(color: HeritageColors.cream, fontSize: 15, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(quest.description, style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12))])), Text(complete ? 'DONE' : '${quest.points} POINTS', style: TextStyle(color: complete ? const Color(0xFF52B788) : HeritageColors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))])));
  Widget _leaderTile(MapEntry<int, Profile> entry) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.05)), borderRadius: BorderRadius.circular(16)), child: Row(children: [Text('#${entry.key + 1}', style: const TextStyle(color: HeritageColors.orange, fontWeight: FontWeight.bold)), const SizedBox(width: 16), Expanded(child: Text(entry.value.fullName, style: const TextStyle(color: HeritageColors.cream, fontWeight: FontWeight.w600))), Text('${entry.value.points} pts', style: const TextStyle(color: Color(0x99FEFAE0), fontSize: 12))]));
  IconData _iconFor(String title) => title.toLowerCase().contains('damage') || title.toLowerCase().contains('protect') ? Icons.shield_outlined : title.toLowerCase().contains('story') || title.toLowerCase().contains('archive') ? Icons.menu_book : Icons.location_on;
  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));
}
