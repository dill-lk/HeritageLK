import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    _QuestItem('🏰', 'The Fort Guardian', 'Scan 3 watchtowers in Galle Fort', 500, Color(0x1AB752B7), Color(0x20B752B7)),
    _QuestItem('🌿', 'Forest Secret Finder', 'Identify 5 endemic plants from Kanneliya', 800, Color(0x1A52B788), Color(0x2052B788)),
    _QuestItem('🐘', 'Wildlife Tracker', 'Spot and document a wild elephant in Minneriya', 1000, Color(0x1AF4A261), Color(0x20F4A261)),
    _QuestItem('🌊', 'Ocean Defender', 'Participate in a Mirissa beach cleanup', 300, Color(0x1A52B788), Color(0x2052B788)),
    _QuestItem('🏛️', 'Ruins Explorer', 'Visit and read the history of 3 ruins in Polonnaruwa', 600, Color(0x1AB752B7), Color(0x20B752B7)),
    _QuestItem('🧗', 'Summit Scaler', 'Climb to the top of Sigiriya Rock Fortress', 1200, Color(0x1AF4A261), Color(0x20F4A261)),
    _QuestItem('🫖', 'Tea Trailblazer', 'Learn about the tea-making process in Nuwara Eliya', 400, Color(0x1A52B788), Color(0x2052B788)),
    _QuestItem('🚂', 'Ella Odyssey', 'Take the scenic train ride from Kandy to Ella', 750, Color(0x1AB752B7), Color(0x20B752B7)),
    _QuestItem('🤿', 'Coral Guardian', 'Explore the coral reefs of Pigeon Island', 850, Color(0x1A52B788), Color(0x2052B788)),
    _QuestItem('🛕', 'Sacred Relic', 'Visit the Temple of the Sacred Tooth Relic', 600, Color(0x1AF4A261), Color(0x20F4A261)),
    _QuestItem("🌅", "Adam's Peak Pilgrim", "Reach the summit of Adam's Peak at sunrise", 1500, Color(0x1AB752B7), Color(0x20B752B7)),
    _QuestItem('🐆', 'Yala Safari', 'Spot a leopard on a safari in Yala National Park', 1100, Color(0x1A52B788), Color(0x2052B788)),
    _QuestItem('🏄', 'Arugam Bay Surfer', 'Catch a wave in the surfing capital', 900, Color(0x1AF4A261), Color(0x20F4A261)),
  ];

  List<_QuestItem> _activeQuests = [];
  List<_QuestItem> _completedQuests = [];
  List<Profile> _leaders = const [
    Profile(id: '1', fullName: 'Sanul Randisa', points: 15200),
    Profile(id: '2', fullName: 'Jinuk Chanthusa', points: 11800),
    Profile(id: '3', fullName: 'Disara Bimsilu', points: 10900),
  ];
  bool _loading = false;
  int _userPoints = 0;
  int _userRank = 0;

  _QuestItem? _activeFlowQuest;
  String _flowStep = 'intro';
  int? _quizSelection;

  @override
  void initState() {
    super.initState();
    _activeQuests = List.from(_fallbackQuests);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!AppConfig.hasSupabase) return;
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final profileRepo = ProfileRepository(client);
      final profile = await profileRepo.currentProfile();
      final completed = await QuestRepository(client).completedQuests();
      final leaders = await profileRepo.leaderboard();
      final quests = await QuestRepository(client).listQuests();
      final rank = profile == null ? 0 : await profileRepo.rankForPoints(profile.points);
      if (mounted) {
        setState(() {
          if (profile != null) {
            _userPoints = profile.points;
            _userRank = rank;
          }
          final completedIds = completed.map((q) => q.questId).toSet();
          if (quests.isNotEmpty) {
            _activeQuests = quests.where((q) => !completedIds.contains(q.id)).map((q) => _QuestItem(q.icon ?? '🏆', q.title, q.description, q.points, const Color(0x1AB752B7), const Color(0x20B752B7))).toList();
            _completedQuests = quests.where((q) => completedIds.contains(q.id)).map((q) => _QuestItem(q.icon ?? '🏆', q.title, q.description, q.points, const Color(0x1A52B788), const Color(0x2052B788))).toList();
          }
          if (leaders.isNotEmpty) _leaders = leaders;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = (_userPoints ~/ 100).clamp(1, 999);
    final progress = _userPoints % 100;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 140), children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Quests', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 32, fontWeight: FontWeight.w800, height: 1.5, letterSpacing: -0.8)),
                const Text('Protect and Discover Heritage', style: TextStyle(color: Color(0x99FEFAE0), fontSize: 14, fontWeight: FontWeight.w500, height: 1.4)),
              ]),
              Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: HeritageColors.orange.withOpacity(0.15)), shape: BoxShape.circle), child: const Icon(Icons.notifications_outlined, color: HeritageColors.cream, size: 20)),
            ]),
            const SizedBox(height: 32),
            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: HeritageColors.orange.withOpacity(0.10)), borderRadius: BorderRadius.circular(32)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Heritage Protector', style: TextStyle(color: HeritageColors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text('$_userPoints', style: const TextStyle(color: HeritageColors.cream, fontSize: 36, fontWeight: FontWeight.w800, height: 1.1)),
                    const SizedBox(width: 8),
                    const Text('Points Earned', style: TextStyle(color: Color(0xFFE9C46A), fontSize: 14)),
                  ]),
                  const SizedBox(height: 2),
                  Text('Global Rank: #${_userRank == 0 ? '-' : _userRank}', style: const TextStyle(color: Color(0x99E9C46A), fontSize: 12)),
                ]),
                Container(width: 48, height: 48, decoration: BoxDecoration(color: HeritageColors.orange.withOpacity(0.10), shape: BoxShape.circle), child: Center(child: Text('Lvl $level', style: const TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold)))),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Progress to next Level', style: TextStyle(color: Color(0x99FEFAE0), fontSize: 12)), Text('$progress%', style: const TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: progress / 100, minHeight: 8, backgroundColor: const Color(0xFF2E1E12), valueColor: const AlwaysStoppedAnimation(HeritageColors.orange))),
            ])),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Top Users', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Season 4', style: TextStyle(color: HeritageColors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ]),
            const SizedBox(height: 16),
            Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: HeritageColors.orange.withOpacity(0.10)), borderRadius: BorderRadius.circular(32)), child: Column(children: _leaders.asMap().entries.map((entry) {
              final i = entry.key;
              final leader = entry.value;
              final score = leader.points >= 1000 ? '${(leader.points / 1000).toStringAsFixed(1)}k' : '${leader.points}';
              return Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), decoration: i < _leaders.length - 1 ? const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0DFEFAE0)))) : null, child: Row(children: [
                Text('${i + 1}', style: const TextStyle(color: Color(0x66FEFAE0), fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(leader.fullName, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w600)), Text(leader.city ?? 'Sri Lanka', style: const TextStyle(color: Color(0x66FEFAE0), fontSize: 12))])),
                Text(score, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.bold)),
              ]));
            }).toList())),
            const SizedBox(height: 32),
            Text('Available Quests', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._activeQuests.map(_questCard),
            if (_completedQuests.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text('Completed Quests', style: GoogleFonts.plusJakartaSans(color: HeritageColors.cream, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._completedQuests.map(_completedCard),
            ],
          ]),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 3)),
          if (_activeFlowQuest != null) _questModal(),
        ]),
      ),
    );
  }

  Widget _questCard(_QuestItem quest) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: quest.border), borderRadius: BorderRadius.circular(32)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(width: 40, height: 48, decoration: BoxDecoration(color: const Color(0xFF1F160E), border: Border.all(color: HeritageColors.orange.withOpacity(0.10)), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(quest.icon, style: const TextStyle(fontSize: 24)))),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(quest.title, style: const TextStyle(color: HeritageColors.cream, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(quest.description, style: const TextStyle(color: Color(0x99FEFAE0), fontSize: 12)),
      ])),
    ]),
    const SizedBox(height: 16),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0x1AE9C46A), borderRadius: BorderRadius.circular(8)), child: Text('+${quest.points} PTS', style: const TextStyle(color: Color(0xFFE9C46A), fontSize: 12, fontWeight: FontWeight.bold))),
      GestureDetector(onTap: () => setState(() { _activeFlowQuest = quest; _flowStep = 'intro'; _quizSelection = null; }), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: HeritageColors.orange, borderRadius: BorderRadius.circular(99)), child: const Text('Start', style: TextStyle(color: HeritageColors.background, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)))),
    ]),
  ]));

  Widget _completedCard(_QuestItem quest) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF241B13), border: Border.all(color: HeritageColors.orange.withOpacity(0.10)), borderRadius: BorderRadius.circular(32)), child: Row(children: [
    Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFF1F160E), border: Border.all(color: HeritageColors.orange.withOpacity(0.10)), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(quest.icon, style: const TextStyle(fontSize: 28)))),
    const SizedBox(width: 16),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(quest.title, style: const TextStyle(color: HeritageColors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF1F160E), borderRadius: BorderRadius.circular(99)), child: const Text('Claimed', style: TextStyle(color: HeritageColors.orange, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
        const SizedBox(width: 8),
        Text('+${quest.points} PTS', style: const TextStyle(color: Color(0xFFE9C46A), fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    ])),
    Container(width: 32, height: 32, decoration: const BoxDecoration(color: HeritageColors.orange, shape: BoxShape.circle), child: const Icon(Icons.check, color: HeritageColors.background, size: 16)),
  ]));

  Widget _questModal() {
    final quest = _activeFlowQuest!;
    return GestureDetector(onTap: () => setState(() => _activeFlowQuest = null), child: Container(color: Colors.black.withOpacity(0.80), child: Align(alignment: Alignment.center, child: GestureDetector(onTap: () {}, child: Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF241B13), border: Border.all(color: HeritageColors.orange.withOpacity(0.20)), borderRadius: BorderRadius.circular(32)), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Align(alignment: Alignment.topRight, child: GestureDetector(onTap: () => setState(() => _activeFlowQuest = null), child: const Icon(Icons.close, color: Colors.white54, size: 24))),
      Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFF1F160E), border: Border.all(color: HeritageColors.orange.withOpacity(0.20)), shape: BoxShape.circle), child: Center(child: Text(quest.icon, style: const TextStyle(fontSize: 32)))),
      const SizedBox(height: 16),
      Text(quest.title, style: const TextStyle(color: HeritageColors.cream, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      if (_flowStep == 'intro') ...[
        Text(quest.description, style: const TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: HeritageColors.orange.withOpacity(0.10), borderRadius: BorderRadius.circular(12)), child: Text('Reward: +${quest.points} PTS', style: const TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        GestureDetector(onTap: () => setState(() => _flowStep = 'checking_location'), child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: HeritageColors.orange, borderRadius: BorderRadius.circular(16)), child: const Text('Confirm Location', style: TextStyle(color: HeritageColors.background, fontWeight: FontWeight.bold, letterSpacing: 0.5), textAlign: TextAlign.center))),
      ] else if (_flowStep == 'checking_location') ...[
        const SizedBox(height: 24),
        const Text('Verifying Location...', style: TextStyle(color: Color(0xFF52B788), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Accessing GPS coordinates', style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 24),
        const CircularProgressIndicator(color: Color(0xFF52B788)),
        const SizedBox(height: 16),
      ] else if (_flowStep == 'quiz') ...[
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0x1A52B788), borderRadius: BorderRadius.circular(99)), child: const Text('Location Verified ✓', style: TextStyle(color: Color(0xFF52B788), fontSize: 13, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        const Text('To complete this quest, answer the guardian\'s question:', style: TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('What is a key historical or ecological fact associated with this location?', style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          ...['Built to protect the coast / Endemic ecosystem', 'Created within the last decade', 'A shopping complex'].asMap().entries.map((entry) => GestureDetector(onTap: () => setState(() => _quizSelection = entry.key), child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _quizSelection == entry.key ? HeritageColors.orange.withOpacity(0.20) : Colors.white.withOpacity(0.05), border: Border.all(color: _quizSelection == entry.key ? HeritageColors.orange : Colors.white.withOpacity(0.05)), borderRadius: BorderRadius.circular(12)), child: Text(entry.value, style: TextStyle(color: _quizSelection == entry.key ? HeritageColors.orange : Colors.white70, fontSize: 14))))),
        ])),
        const SizedBox(height: 16),
        GestureDetector(onTap: _quizSelection == 0 ? () => setState(() { _flowStep = 'completed'; _completedQuests.add(quest); _activeQuests.remove(quest); _activeFlowQuest = null; }) : null, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: _quizSelection == 0 ? const Color(0xFF52B788) : Colors.white10, borderRadius: BorderRadius.circular(16)), child: Text(_quizSelection == 0 ? 'Claim Reward' : 'Select Correct Answer', style: TextStyle(color: _quizSelection == 0 ? Colors.white : Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 0.5), textAlign: TextAlign.center))),
      ] else if (_flowStep == 'completed') ...[
        Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0x2052B788), shape: BoxShape.circle), child: const Center(child: Icon(Icons.check, color: Color(0xFF52B788), size: 32))),
        const SizedBox(height: 16),
        const Text('Quest Completed!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('+${quest.points} PTS', style: const TextStyle(color: HeritageColors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        GestureDetector(onTap: () => setState(() => _activeFlowQuest = null), child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)), child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5), textAlign: TextAlign.center))),
      ],
    ]))));
  }
}

class _QuestItem {
  final String icon;
  final String title;
  final String description;
  final int points;
  final Color accent;
  final Color border;
  const _QuestItem(this.icon, this.title, this.description, this.points, this.accent, this.border);
}
