import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../services/archive_repository.dart';
import '../services/heritage_api.dart';
import '../theme/heritage_colors.dart';

class GenerateArchiveScreen extends StatefulWidget {
  const GenerateArchiveScreen({super.key});

  @override
  State<GenerateArchiveScreen> createState() => _GenerateArchiveScreenState();
}

class _GenerateArchiveScreenState extends State<GenerateArchiveScreen> {
  final _topic = TextEditingController();
  final _api = HeritageApi();
  String _result = '';
  bool _loading = false;
  bool _saving = false;

  @override
  void dispose() {
    _topic.dispose();
    _api.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_topic.text.trim().isEmpty || _loading) return;
    setState(() => _loading = true);
    try {
      final result = await _api.generateArchive(_topic.text.trim());
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) setState(() => _result = 'Unable to generate archive right now. $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_result.isEmpty || _saving || !AppConfig.hasSupabase) return;
    setState(() => _saving = true);
    try {
      final record = await ArchiveRepository(Supabase.instance.client).createGeneratedArchive(title: _topic.text.trim(), content: _result);
      if (mounted) Navigator.of(context).pushReplacementNamed(record == null ? '/archive' : '/archive/${record.id}', arguments: record);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save archive. $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          GestureDetector(onTap: () => Navigator.of(context).pushReplacementNamed('/archive'), child: const Icon(Icons.arrow_back, color: HeritageColors.orange, size: 24)),
          const SizedBox(height: 32),
          const CircleAvatar(radius: 32, backgroundColor: Color(0x33F4A261), child: Icon(Icons.auto_awesome, color: HeritageColors.orange, size: 30)),
          const SizedBox(height: 24),
          const Text('Admin: Generate Archive', textAlign: TextAlign.center, style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Enter a topic to generate a comprehensive historical archive using NVIDIA NIM AI.', textAlign: TextAlign.center, style: TextStyle(color: Color(0x99FFFFFF), fontSize: 14, height: 1.6)),
          const SizedBox(height: 28),
          TextField(controller: _topic, onSubmitted: (_) => _generate(), style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'e.g. Ancient Sigiriya Frescoes', hintStyle: const TextStyle(color: Color(0x66FFFFFF)), filled: true, fillColor: const Color(0xFF1A1311), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: HeritageColors.orange.withOpacity(0.30))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: HeritageColors.orange.withOpacity(0.30))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: HeritageColors.orange)), contentPadding: const EdgeInsets.all(18))),
          const SizedBox(height: 16),
          SizedBox(height: 56, child: FilledButton(onPressed: _loading ? null : _generate, style: FilledButton.styleFrom(backgroundColor: HeritageColors.orange, foregroundColor: HeritageColors.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (_loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: HeritageColors.background, strokeWidth: 2)),
            if (_loading) const SizedBox(width: 12),
            Text(_loading ? 'Generating...' : 'Generate Post', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]))),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.08)), borderRadius: BorderRadius.circular(20)), child: Text(_result, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 14, height: 1.6))),
            const SizedBox(height: 16),
            SizedBox(height: 56, child: FilledButton(onPressed: AppConfig.hasSupabase && !_saving ? _save : null, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF52B788), disabledBackgroundColor: const Color(0x6652B788), foregroundColor: HeritageColors.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(_saving ? 'Saving...' : 'Save to Archive', style: const TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ],
      ),
    ),
  );
}
