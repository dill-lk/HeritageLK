import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/archive_record.dart';
import '../services/archive_repository.dart';
import '../theme/heritage_colors.dart';

class ArchiveDetailScreen extends StatefulWidget {
  const ArchiveDetailScreen({super.key, this.archiveId});

  final String? archiveId;

  @override
  State<ArchiveDetailScreen> createState() => _ArchiveDetailScreenState();
}

class _ArchiveDetailScreenState extends State<ArchiveDetailScreen> {
  ArchiveRecord? _record;
  bool _loading = false;

  static const _fallback = ArchiveRecord(
    id: 'traditional-mask-making',
    title: 'Traditional Mask Making',
    location: 'AMBALANGODA, SRI LANKA',
    category: 'ANCIENT CRAFTSMANSHIP',
    content: 'In the coastal town of Ambalangoda, the ancient art of "Wesmuhunu" (mask making) has been preserved through generations, breathing life into the folklore and spiritual rituals of the island.\n\nThe Heritage of Kaduru Wood\n\nThe process begins with the careful selection of Kaduru, a soft, light wood found in marshy lands. The timber is seasoned with smoke for several weeks to prevent decay and insect infestation, a practice unchanged for centuries.\n\nThe Spirit of Gara Yaka\n\nAmong the most iconic creations is the Gara Yaka mask. Characterized by its large, bulging eyes, protruding tongue, and vibrant cobra-like ears, it is central to Tovil exorcism rituals.',
    image: 'https://images.unsplash.com/photo-1544640808-32cb4fbad06e?q=80&w=900&auto=format&fit=crop',
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (_record == null && argument is ArchiveRecord) _record = argument;
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    if (_record != null || widget.archiveId == null || !AppConfig.hasSupabase || _loading) return;
    setState(() => _loading = true);
    try {
      final record = await ArchiveRepository(Supabase.instance.client).getArchive(widget.archiveId!);
      if (mounted && record != null) setState(() => _record = record);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = _record ?? _fallback;
    final parts = _contentParts(record.content);

    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(fit: StackFit.expand, children: [
                _heroImage(record.image),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00100E0A), Color(0x66100E0A), HeritageColors.background]))),
                Positioned(top: 16, left: 24, right: 24, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _round(context, Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/archive')),
                  _round(context, Icons.bookmark, () {}, filled: true),
                ])),
                if (_loading) const Center(child: CircularProgressIndicator(color: HeritageColors.orange)),
                Positioned(left: 24, right: 24, bottom: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: HeritageColors.orange.withValues(alpha:0.10), border: Border.all(color: HeritageColors.orange.withValues(alpha:0.20)), borderRadius: BorderRadius.circular(4)), child: Text(record.category.toUpperCase(), style: const TextStyle(color: HeritageColors.orange, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
                  const SizedBox(height: 12),
                  Text(record.title, style: const TextStyle(color: Colors.white, fontFamily: 'Playfair Display', fontSize: 36, fontWeight: FontWeight.bold, height: 1.1)),
                  if ((record.subtitle ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(record.subtitle!, style: const TextStyle(color: Color(0xFFF4A261), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                  const SizedBox(height: 12),
                  Row(children: [const Icon(Icons.location_on, color: HeritageColors.orange, size: 14), const SizedBox(width: 6), Text(record.location.toUpperCase(), style: const TextStyle(color: HeritageColors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))]),
                ])),
              ]),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(24, 32, 24, 48), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.only(left: 20), decoration: const BoxDecoration(border: Border(left: BorderSide(color: HeritageColors.orange, width: 3))), child: Text(parts.first, style: const TextStyle(color: Color(0xCCFFFFFF), fontFamily: 'Playfair Display', fontStyle: FontStyle.italic, fontSize: 15, height: 1.7))),
              const SizedBox(height: 40),
              ...parts.skip(1).map(_contentBlock),
              Row(children: [
                _image(record.image ?? 'https://images.unsplash.com/photo-1544640808-32cb4fbad06e?q=80&w=500&auto=format&fit=crop'),
                const SizedBox(width: 12),
                _image('https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?q=80&w=500&auto=format&fit=crop'),
              ]),
              const SizedBox(height: 32),
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF1A1311), border: Border.all(color: Colors.white.withValues(alpha:0.05)), borderRadius: BorderRadius.circular(24)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.info_outline, color: HeritageColors.orange, size: 20), SizedBox(width: 8), Text('Did you know?', style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold))]),
                SizedBox(height: 10),
                Text('Traditional colors were derived from natural sources: white clay, yellow resin, and charred coconut shells for deep blacks.', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13, height: 1.7)),
              ])),
            ])),
          ]),
        ]),
      ),
    );
  }

  Widget _round(BuildContext context, IconData icon, VoidCallback action, {bool filled = false}) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black.withValues(alpha:0.40), border: Border.all(color: Colors.white.withValues(alpha:0.10)), shape: BoxShape.circle), child: Icon(icon, color: filled ? HeritageColors.orange : Colors.white, size: 20)));
  Widget _image(String url) => Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: CachedNetworkImage(imageUrl: url, height: 150, fit: BoxFit.cover, httpHeaders: const {'User-Agent': 'HeritageLK/1.0 (Flutter; Android)', 'Accept': 'image/webp,image/png,image/*,*/*;q=0.8'}, errorWidget: (_, __, ___) => const ColoredBox(color: HeritageColors.brown))));
  Widget _heroImage(String? url) => url == null || url.isEmpty ? const ColoredBox(color: HeritageColors.brown) : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, httpHeaders: const {'User-Agent': 'HeritageLK/1.0 (Flutter; Android)', 'Accept': 'image/webp,image/png,image/*,*/*;q=0.8'}, errorWidget: (_, __, ___) => const ColoredBox(color: HeritageColors.brown));

  Widget _contentBlock(String text) {
    final isHeading = text.length < 60 && !text.contains('.');
    return Padding(padding: const EdgeInsets.only(bottom: 24), child: Text(text, style: TextStyle(color: isHeading ? HeritageColors.orange : const Color(0xB3FFFFFF), fontSize: isHeading ? 20 : 14, fontWeight: isHeading ? FontWeight.bold : FontWeight.normal, height: isHeading ? 1.3 : 1.8)));
  }

  List<String> _contentParts(String value) => value.replaceAll('#', '').replaceAll('*', '').split(RegExp(r'\n\s*\n')).map((part) => part.trim()).where((part) => part.isNotEmpty).toList(growable: false).ifEmpty([_fallback.content]);
}

extension _IfEmptyList on List<String> {
  List<String> ifEmpty(List<String> fallback) => isEmpty ? fallback : this;
}

