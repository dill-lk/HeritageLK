import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/archive_record.dart';
import '../services/archive_repository.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  int _tab = 0;
  bool _loading = false;
  String? _error;
  final _search = TextEditingController();
  final _tabs = const ['All Records', 'Artifacts', 'Oral History', 'Ancient Sites'];

  List<ArchiveRecord> _items = const [
    ArchiveRecord(id: 'galle-dutch-fort', title: 'Galle Dutch Fort', location: 'GALLE, SRI LANKA', category: 'Ancient Sites', content: 'A living monument to Sri Lanka\'s colonial history.'),
    ArchiveRecord(id: 'sigiriya-rock-fortress', title: 'Sigiriya Rock Fortress', location: 'MATALE, SRI LANKA', category: 'Ancient Sites', content: 'The ancient rock fortress and palace ruin.'),
    ArchiveRecord(id: 'traditional-mask-making', title: 'Traditional Mask Making', location: 'AMBALANGODA, SRI LANKA', category: 'Artifacts', content: 'A craft passed through generations.'),
  ];

  @override
  void initState() {
    super.initState();
    _loadArchives();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadArchives() async {
    if (!AppConfig.hasSupabase) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await ArchiveRepository(Supabase.instance.client).listArchives();
      if (mounted && rows.isNotEmpty) setState(() => _items = rows);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final items = _items.where((item) {
      final matchesTab = _tab == 0 || item.category == _tabs[_tab];
      final matchesSearch = query.isEmpty || item.title.toLowerCase().contains(query) || item.location.toLowerCase().contains(query) || item.content.toLowerCase().contains(query);
      return matchesTab && matchesSearch;
    }).toList();
    final featured = _tab == 0 && query.isEmpty ? _items.firstOrNull : null;

    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 140), children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')),
              const Text('Archive', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 20)),
              _shingoButton(),
            ]),
            const SizedBox(height: 24),
            TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Search history & archives...', hintStyle: const TextStyle(color: Color(0x66FFFFFF), fontSize: 14), prefixIcon: const Icon(Icons.search, color: Color(0x66FFFFFF)), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))))),
            const SizedBox(height: 24),
            if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Column(children: [CircularProgressIndicator(color: HeritageColors.orange), SizedBox(height: 12), Text('Unearthing archives...', style: TextStyle(color: Color(0x99F4A261), fontSize: 14, fontWeight: FontWeight.w600))])),
            if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text('Archive sync unavailable. Showing saved records.', textAlign: TextAlign.center, style: TextStyle(color: HeritageColors.orange.withOpacity(0.60), fontSize: 13))),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _tabs.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _tab == i ? HeritageColors.orange : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: _tab == i ? [BoxShadow(color: HeritageColors.orange.withOpacity(0.40), blurRadius: 15)] : null,
                        ),
                        child: Text(
                          _tabs[i],
                          style: TextStyle(
                            color: _tab == i ? HeritageColors.background : const Color(0x99FFFFFF),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (featured != null) ...[
              Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: HeritageColors.orange, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text('Newly Discovered', style: TextStyle(color: HeritageColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ]),
              const SizedBox(height: 16),
              _featured(featured),
              const SizedBox(height: 24),
            ],
            ...items.map(_archiveTile),
            if (items.isEmpty && !_loading) _emptyState(),
          ]),
          Positioned(bottom: 108, right: 24, child: GestureDetector(onTap: () => Navigator.of(context).pushNamed('/archive/upload'), child: Container(width: 56, height: 56, decoration: BoxDecoration(color: HeritageColors.orange, shape: BoxShape.circle, boxShadow: [BoxShadow(color: HeritageColors.orange.withOpacity(0.40), blurRadius: 20, offset: const Offset(0, 4))]), child: const Icon(Icons.add, color: HeritageColors.background, size: 28)))),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 4)),
        ]),
      ),
    );
  }

  Widget _shingoButton() => GestureDetector(onTap: () => Navigator.of(context).pushNamed('/archive/shingo'), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0x33E9C46A), border: Border.all(color: const Color(0x66E9C46A)), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: Color(0xFFE9C46A), size: 20)));
  Widget _round(IconData icon, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));

  Widget _featured(ArchiveRecord item) => InkWell(onTap: () => Navigator.of(context).pushNamed('/archive/${item.id}', arguments: item), borderRadius: BorderRadius.circular(24), child: Container(height: 320, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.10)), borderRadius: BorderRadius.circular(24)), child: Stack(fit: StackFit.expand, children: [
    _recordImage(item.image),
    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00100E0A), Color(0x66100E0A), HeritageColors.background]))),
    const DecoratedBox(decoration: BoxDecoration(color: Color(0x33000000))),
    Positioned(left: 24, right: 24, bottom: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.location_on, color: HeritageColors.orange, size: 12), const SizedBox(width: 4), Text(item.location, style: const TextStyle(color: HeritageColors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2))]),
      const SizedBox(height: 8),
      Text(item.title, style: const TextStyle(color: Colors.white, fontFamily: 'Playfair Display', fontSize: 28, height: 1.1, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      Text(_clean(item.content), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 14)),
    ])),
  ])));

  Widget _archiveTile(ArchiveRecord item) => InkWell(onTap: () => Navigator.of(context).pushNamed('/archive/${item.id}', arguments: item), borderRadius: BorderRadius.circular(20), child: Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.05)), borderRadius: BorderRadius.circular(20)), child: Row(children: [
    ClipRRect(borderRadius: BorderRadius.circular(16), child: SizedBox(width: 88, height: 88, child: _recordImage(item.image, small: true))),
    const SizedBox(width: 16),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.location_on, color: HeritageColors.orange, size: 10), const SizedBox(width: 4), Text(item.location, style: const TextStyle(color: HeritageColors.orange, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))]),
      const SizedBox(height: 6),
      Text(item.title, style: const TextStyle(color: Colors.white, fontFamily: 'Playfair Display', fontSize: 16)),
      const SizedBox(height: 6),
      Text(_clean(item.content), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12, height: 1.4)),
    ])),
    Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), shape: BoxShape.circle), child: const Icon(Icons.chevron_right, color: Color(0x99FFFFFF), size: 16)),
  ])));

  Widget _recordImage(String? image, {bool small = false}) => image == null || image.isEmpty
      ? Container(color: const Color(0xFF342116), child: Icon(Icons.account_balance, color: HeritageColors.orange, size: small ? 30 : 52))
      : Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF342116), child: Icon(Icons.account_balance, color: HeritageColors.orange, size: small ? 30 : 52)));

  Widget _emptyState() => Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.05)), borderRadius: BorderRadius.circular(24)), child: const Column(children: [Icon(Icons.menu_book_outlined, color: Color(0x33FFFFFF), size: 40), SizedBox(height: 16), Text('Record Not Found', style: TextStyle(color: Colors.white, fontFamily: 'Playfair Display', fontSize: 18)), SizedBox(height: 8), Text('There are no records matching your search in the chronicles.', textAlign: TextAlign.center, style: TextStyle(color: Color(0x80FFFFFF), fontSize: 13, height: 1.5))]));

  String _clean(String value) => value.replaceAll('#', '').replaceAll('*', '');
}
