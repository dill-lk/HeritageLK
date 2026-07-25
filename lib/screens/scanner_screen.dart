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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _site,
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
                      Row(children: [Expanded(child: _info('ERA', 'Ancient')), Expanded(child: _info('TYPE', _result?.locationName ?? 'Heritage'))]),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav()),
        ],
      ),
    ),
  );
  Widget _info(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 4), Text(value, style: const TextStyle(color: HeritageColors.cream, fontWeight: FontWeight.bold))]);
  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));
}
