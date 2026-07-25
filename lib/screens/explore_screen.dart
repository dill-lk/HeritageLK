import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/heritage_site.dart';
import '../services/heritage_api.dart';
import '../services/heritage_site_repository.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  final _api = HeritageApi();
  List<HeritageSite> _sites = const [
    HeritageSite(id: 'galle-dutch-fort', title: 'Galle Dutch Fort', summary: 'A living monument to Sri Lanka\'s colonial history.', locationName: 'Galle'),
    HeritageSite(id: 'sigiriya-rock-fortress', title: 'Sigiriya Rock Fortress', summary: 'The ancient rock fortress and palace ruin.', locationName: 'Matale'),
    HeritageSite(id: 'dambulla-cave-temple', title: 'Dambulla Cave Temple', summary: 'A cave temple complex with ancient murals and statues.', locationName: 'Dambulla'),
  ];
  HeritageSite? _selected;
  String? _aiDetails;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  @override
  void dispose() {
    _search.dispose();
    _api.dispose();
    super.dispose();
  }

  Future<void> _loadSites() async {
    if (!AppConfig.hasSupabase) return;
    setState(() => _loading = true);
    try {
      final rows = await HeritageSiteRepository(Supabase.instance.client).listSites();
      if (mounted && rows.isNotEmpty) setState(() => _sites = rows);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _select(HeritageSite site) async {
    setState(() {
      _selected = site;
      _aiDetails = null;
    });
    try {
      final details = await _api.siteDetails(site.title);
      final aiText = details['details']?.toString() ?? details['summary']?.toString() ?? site.summary;
      if (mounted) setState(() => _aiDetails = aiText);
    } catch (_) {
      if (mounted) setState(() => _aiDetails = site.summary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final results = _sites.where((site) => q.isEmpty || site.title.toLowerCase().contains(q) || (site.locationName ?? '').toLowerCase().contains(q)).toList();
    final selected = _selected ?? (results.isEmpty ? null : results.first);
    return Scaffold(body: SafeArea(child: Stack(children: [ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 130), children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')), const Text('Explore', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 22)), _round(Icons.filter_list, () {})]), const SizedBox(height: 24), TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Search heritage sites...', hintStyle: const TextStyle(color: Color(0x66FFFFFF)), prefixIcon: const Icon(Icons.search, color: Color(0x66FFFFFF)), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))))), if (_loading) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator(color: HeritageColors.orange, backgroundColor: Color(0x1AFFFFFF))), const SizedBox(height: 16), Container(height: 240, decoration: BoxDecoration(color: const Color(0xFF241B12), border: Border.all(color: HeritageColors.orange.withOpacity(0.20)), borderRadius: BorderRadius.circular(24)), child: Stack(children: [CustomPaint(size: Size.infinite, painter: _MapPainter(points: results)), if (selected?.imageUrl != null) ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(selected!.imageUrl!, width: double.infinity, height: 240, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.22), errorBuilder: (_, __, ___) => const SizedBox.shrink())), const Positioned(left: 20, bottom: 18, child: Text('Sri Lanka Heritage Map', style: TextStyle(color: HeritageColors.cream, fontWeight: FontWeight.bold))), const Positioned(right: 20, top: 18, child: Icon(Icons.my_location, color: HeritageColors.orange))])), if (selected != null) _details(selected), const SizedBox(height: 24), const Text('NEARBY HERITAGE', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)), const SizedBox(height: 12), ...results.map(_site)],), const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav())])));
  }

  Widget _details(HeritageSite site) => Container(margin: const EdgeInsets.only(top: 16, bottom: 8), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: HeritageColors.orange.withOpacity(0.16)), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(site.title, style: const TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(site.locationName ?? 'Sri Lanka', style: const TextStyle(color: HeritageColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 10), Text(_aiDetails ?? site.summary, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, height: 1.6))]));
  Widget _site(HeritageSite site) => InkWell(onTap: () => _select(site), borderRadius: BorderRadius.circular(20), child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: (_selected?.id == site.id ? HeritageColors.orange : Colors.white).withOpacity(0.07)), borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.location_on, color: HeritageColors.orange), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(site.title, style: const TextStyle(color: HeritageColors.cream, fontSize: 15, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('${site.locationName ?? 'History'}  •  Sri Lanka', style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12))])), const Icon(Icons.chevron_right, color: Color(0x80FFFFFF))])));
  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));
}

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.points});

  final List<HeritageSite> points;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()..color = HeritageColors.orange.withOpacity(0.16)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = 0.0; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final pin = Paint()..color = HeritageColors.orange;
    for (var i = 0; i < points.length.clamp(1, 8); i++) {
      final x = (48 + (i * 63) % (size.width - 80)).toDouble();
      final y = (52 + (i * 47) % (size.height - 95)).toDouble();
      canvas.drawCircle(Offset(x, y), 6, pin);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => oldDelegate.points.length != points.length;
}
