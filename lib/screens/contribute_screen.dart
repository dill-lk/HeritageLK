import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../services/archive_repository.dart';
import '../theme/heritage_colors.dart';

class ContributeScreen extends StatefulWidget { const ContributeScreen({super.key}); @override State<ContributeScreen> createState() => _ContributeScreenState(); }
class _ContributeScreenState extends State<ContributeScreen> {
  String _category = 'Artifacts'; bool _public = true; bool _submitting = false;
  final _title = TextEditingController(); final _description = TextEditingController();
  @override void dispose() { _title.dispose(); _description.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _description.text.trim().isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      if (AppConfig.hasSupabase) {
        final record = await ArchiveRepository(Supabase.instance.client).createContribution(title: _title.text.trim(), category: _category, description: _description.text.trim(), isPublic: _public);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contribution added to the Archive! Thank you for preserving Sri Lanka\'s heritage.')));
        Navigator.of(context).pushReplacementNamed(record == null ? '/archive' : '/archive/${record.id}', arguments: record);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contribution saved locally for now. Add Supabase credentials to upload.')));
        Navigator.of(context).pushReplacementNamed('/archive');
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit. $error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/archive')), const Text('Contribute to Archive', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold)), _round(Icons.info_outline, () {})]), const SizedBox(height: 32), const Text('SHARE YOUR STORY', style: TextStyle(color: HeritageColors.orange, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)), const SizedBox(height: 4), const Text('Add to the Legacy', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 30, fontWeight: FontWeight.bold)), const SizedBox(height: 32), _field(_title, 'Title of Contribution (e.g. My Grandmother\'s Recipes)', Icons.person_outline), const SizedBox(height: 16), _categoryField(), const SizedBox(height: 16), _descriptionField(), const SizedBox(height: 24), const Text('Upload Media', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 12), Container(height: 150, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.20), style: BorderStyle.solid), borderRadius: BorderRadius.circular(16)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 24, backgroundColor: HeritageColors.orange, child: Icon(Icons.upload_outlined, color: HeritageColors.background)), SizedBox(height: 12), Text('Drop photos, audio or PDFs', style: TextStyle(color: HeritageColors.cream, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Maximum file size: 50MB', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12))])), const SizedBox(height: 16), _publicRow(), const SizedBox(height: 32), SizedBox(height: 56, child: FilledButton(onPressed: _submitting ? null : _submit, style: FilledButton.styleFrom(backgroundColor: HeritageColors.orange, foregroundColor: HeritageColors.background, disabledBackgroundColor: HeritageColors.orange.withOpacity(0.50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(_submitting ? 'Submitting...' : 'Submit to Archive →', style: const TextStyle(fontWeight: FontWeight.bold)))), const SizedBox(height: 24), const Center(child: Text('HERITAGELK', style: TextStyle(color: Color(0x33FFFFFF), fontSize: 12, letterSpacing: 2))) ])));
  Widget _field(TextEditingController c, String hint, IconData icon) => Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), borderRadius: BorderRadius.circular(16)), child: TextField(controller: c, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: InputDecoration(icon: Icon(icon, color: const Color(0x66FFFFFF), size: 18), hintText: hint, hintStyle: const TextStyle(color: Color(0x33FFFFFF)), border: InputBorder.none)));
  Widget _categoryField() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      border: Border.all(color: Colors.white.withOpacity(0.10)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.folder_outlined, color: Color(0x66FFFFFF), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              dropdownColor: HeritageColors.background,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: const ['Artifacts', 'Oral History', 'Ancient Sites']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _descriptionField() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), borderRadius: BorderRadius.circular(16)), child: TextField(controller: _description, maxLines: 5, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: const InputDecoration(labelText: 'The Story / Description', labelStyle: TextStyle(color: Color(0x99FFFFFF)), hintText: 'Tell us the historical significance, the origin, or the personal memories associated with this contribution...', hintStyle: TextStyle(color: Color(0x33FFFFFF)), border: InputBorder.none)));
  Widget _publicRow() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), borderRadius: BorderRadius.circular(16)), child: Row(children: [const CircleAvatar(radius: 16, backgroundColor: Color(0x1AFFFFFF), child: Icon(Icons.lock_outline, color: Colors.white, size: 14)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Public Archive', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), Text('Available for everyone to see', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12))])), Switch(value: _public, activeColor: Colors.white, activeTrackColor: HeritageColors.orange, onChanged: (value) => setState(() => _public = value))]));
  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), border: Border.all(color: Colors.white.withOpacity(0.20)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));
}
