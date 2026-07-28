import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../services/damage_report_repository.dart';
import '../theme/heritage_colors.dart';

class ReportDamageScreen extends StatefulWidget {
  const ReportDamageScreen({super.key});

  @override
  State<ReportDamageScreen> createState() => _ReportDamageScreenState();
}

class _ReportDamageScreenState extends State<ReportDamageScreen> {
  String _type = 'Structural Cracks';
  bool _submitting = false;
  String _location = 'Galle Fort, Southern Wall';
  final _details = TextEditingController();
  final _types = const ['Structural Cracks', 'Vandalism', 'Water Damage', 'Erosion', 'Vegetation Overgrowth'];
  final ImagePicker _picker = ImagePicker();
  final List<String> _photos = [];

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (image != null && mounted) {
        setState(() => _photos.add(image.path));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
    }
  }

  Future<void> _submit() async {
    if (_details.text.trim().isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      if (AppConfig.hasSupabase) {
        if (Supabase.instance.client.auth.currentUser == null) {
          if (mounted) Navigator.of(context).pushReplacementNamed('/login');
          return;
        }
        await DamageReportRepository(Supabase.instance.client).submit(damageType: _type, details: _details.text.trim(), location: _location);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you for protecting Sri Lanka\'s heritage.')));
        setState(() { _photos.clear(); _details.clear(); });
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit report. $error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')),
            const Text('Report Damage', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.bold)),
            _round(Icons.notifications_none, () {}),
          ]),
          const SizedBox(height: 28),
          Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: const Color(0x4D52B788)), borderRadius: BorderRadius.circular(30)), child: const Row(children: [
            Icon(Icons.emoji_events, color: Color(0xFF52B788), size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Community Protection', style: TextStyle(color: Color(0xFF52B788), fontSize: 14, fontWeight: FontWeight.w600))),
            Text('+100 Points', style: TextStyle(color: HeritageColors.orange, fontSize: 14, fontWeight: FontWeight.bold)),
          ])),
          const SizedBox(height: 28),
          _label('LOCATION'),
          _card(Row(children: [
            const Icon(Icons.location_on, color: Color(0xFF52B788)),
            const SizedBox(width: 12),
            Expanded(child: TextField(decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter location', hintStyle: TextStyle(color: Color(0x4DFFFFFF))), style: const TextStyle(color: HeritageColors.cream, fontSize: 14), onChanged: (v) => _location = v.trim().isEmpty ? _location : v.trim())),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0x662D6A4F), border: Border.all(color: const Color(0x3352B788)), borderRadius: BorderRadius.circular(20)), child: const Text('GPS READY', style: TextStyle(color: Color(0xFF52B788), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
          ])),
          const SizedBox(height: 24),
          _label('TYPE OF DAMAGE'),
          _card(DropdownButtonHideUnderline(child: DropdownButton<String>(value: _type, dropdownColor: HeritageColors.background, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, color: Color(0x66FFFFFF)), style: const TextStyle(color: HeritageColors.cream, fontSize: 14), items: _types.map((value) => DropdownMenuItem(value: value, child: Row(children: [const Icon(Icons.warning_amber, color: HeritageColors.orange, size: 20), const SizedBox(width: 12), Text(value)]))).toList(), onChanged: (value) => setState(() => _type = value!)))),
          const SizedBox(height: 24),
          _label('VISUAL EVIDENCE'),
          Row(children: [
            GestureDetector(onTap: _pickImage, child: Container(width: 96, height: 96, decoration: BoxDecoration(color: HeritageColors.orange.withValues(alpha:0.05), border: Border.all(color: HeritageColors.orange.withValues(alpha:0.40)), borderRadius: BorderRadius.circular(16)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, color: HeritageColors.orange), SizedBox(height: 4), Text('ADD PHOTO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))]))),
            const SizedBox(width: 16),
            ..._photos.map((path) => ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(path), width: 96, height: 96, fit: BoxFit.cover))),
          ]),
          const SizedBox(height: 24),
          _label('DETAILS'),
          _card(TextField(controller: _details, maxLines: 4, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: const InputDecoration(hintText: 'Describe the damage you observed...', hintStyle: TextStyle(color: Color(0x4DFFFFFF)), border: InputBorder.none))),
          const SizedBox(height: 28),
          SizedBox(height: 56, child: FilledButton(onPressed: _submitting ? null : _submit, style: FilledButton.styleFrom(backgroundColor: HeritageColors.orange, disabledBackgroundColor: HeritageColors.orange.withValues(alpha:0.50), foregroundColor: HeritageColors.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(_submitting ? 'Submitting...' : 'Submit Report', style: const TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    ),
  );

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(text, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)));
  Widget _card(Widget child) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: Colors.white.withValues(alpha:0.10)), borderRadius: BorderRadius.circular(16)), child: child);
  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.10), border: Border.all(color: Colors.white.withValues(alpha:0.20)), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 20)));
}
