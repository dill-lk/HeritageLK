import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/heritage_site.dart';
import '../services/heritage_site_repository.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _site = TextEditingController();
  HeritageSite? _result;
  bool _scanned = false;
  bool _loading = false;
  int _tab = 0;
  bool _reconstructMode = false;

  static const _tabs = ['Sites', 'Plants', 'Wildlife'];

  @override
  void dispose() {
    _site.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final query = _site.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _scanned = true;
    });
    try {
      HeritageSite? site;
      if (AppConfig.hasSupabase) {
        site = await HeritageSiteRepository(Supabase.instance.client).findByTitle(query);
      }
      if (mounted) {
        setState(() => _result = site ?? HeritageSite(id: query, title: query, summary: 'Historical heritage site identified in Sri Lanka.', locationName: 'Sri Lanka'));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')),
                  const Text('Scanner', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 22)),
                  _round(Icons.info_outline, () {}),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 300,
                decoration: BoxDecoration(color: const Color(0xFF1A1311), borderRadius: BorderRadius.circular(24), border: Border.all(color: HeritageColors.orange.withOpacity(0.20))),
                child: Stack(
                  children: [
                    if (_result?.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(_result!.imageUrl!, width: double.infinity, height: 300, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.30), errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                      ),
                    Center(child: Icon(_scanned ? Icons.account_balance : Icons.camera_alt_outlined, size: 76, color: HeritageColors.orange)),
                    if (_loading) const Center(child: CircularProgressIndicator(color: HeritageColors.orange)),
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('SCAN HERITAGE', style: TextStyle(color: HeritageColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.flash_on, color: HeritageColors.cream)),
                        ],
                      ),
                    ),
                    if (!_scanned)
                      const Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Text('Point your camera at a heritage site or artifact', textAlign: TextAlign.center, style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13)),
                      ),
                    if (_reconstructMode)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(color: HeritageColors.orange.withOpacity(0.08), borderRadius: BorderRadius.circular(24), border: Border.all(color: HeritageColors.orange.withOpacity(0.30), width: 2)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.view_in_ar, size: 64, color: HeritageColors.orange),
                            const SizedBox(height: 12),
                            const Text('3D RECONSTRUCT', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            const SizedBox(height: 4),
                            const Text('Point camera at a structure to reconstruct', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _tabButton(0, Icons.location_on, 'Sites')),
                const SizedBox(width: 8),
                Expanded(child: _tabButton(1, Icons.eco, 'Plants')),
                const SizedBox(width: 8),
                Expanded(child: _tabButton(2, Icons.pets, 'Wildlife')),
              ]),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _site,
                      onSubmitted: (_) => _scan(),
                      decoration: InputDecoration(
                        hintText: 'Enter place to scan...',
                        hintStyle: const TextStyle(color: Color(0x66FFFFFF)),
                        prefixIcon: const Icon(Icons.search, color: Color(0x99FFFFFF)),
                        filled: true,
                        fillColor: const Color(0xCC1A1311),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    width: 56,
                    child: FilledButton(
                      onPressed: _loading ? null : _scan,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Icon(Icons.document_scanner_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _reconstructMode = !_reconstructMode),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _reconstructMode ? HeritageColors.orange.withOpacity(0.15) : Colors.white.withOpacity(0.05), border: Border.all(color: _reconstructMode ? HeritageColors.orange.withOpacity(0.40) : Colors.white.withOpacity(0.10)), borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Icon(Icons.view_in_ar, color: _reconstructMode ? HeritageColors.orange : Colors.white54, size: 22),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('3D Reconstruct', style: TextStyle(color: _reconstructMode ? HeritageColors.cream : Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('View heritage sites in augmented reality', style: TextStyle(color: _reconstructMode ? const Color(0x99FEFAE0) : const Color(0x66FFFFFF), fontSize: 12)),
                    ])),
                    Icon(_reconstructMode ? Icons.toggle_on : Icons.toggle_off, color: _reconstructMode ? HeritageColors.orange : Colors.white38, size: 32),
                  ]),
                ),
              ),
              if (_scanned) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.08)), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(_result?.title ?? _site.text, style: const TextStyle(color: HeritageColors.cream, fontSize: 24, fontWeight: FontWeight.bold))),
                          const Text('92%', style: TextStyle(color: HeritageColors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text('MATCH', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 10, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text(_result?.summary ?? 'Historical heritage site identified in Sri Lanka.', style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 14, height: 1.6)),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _info('ERA', 'Ancient')),
                        Expanded(child: _info('TYPE', _result?.locationName ?? 'Heritage')),
                        Expanded(child: _info('MATERIAL', 'Stone')),
                      ]),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 2)),
        ],
      ),
    ),
  );

  Widget _tabButton(int index, IconData icon, String label) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: selected ? HeritageColors.orange.withOpacity(0.15) : Colors.white.withOpacity(0.05), border: Border.all(color: selected ? HeritageColors.orange.withOpacity(0.40) : Colors.white.withOpacity(0.08)), borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: selected ? HeritageColors.orange : Colors.white54, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: selected ? HeritageColors.cream : Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _info(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 4), Text(value, style: const TextStyle(color: HeritageColors.cream, fontWeight: FontWeight.bold))]);
  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));
}
