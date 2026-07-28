import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class _Visit {
  final String id;
  final String imagePath;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  _Visit({required this.id, required this.imagePath, required this.latitude, required this.longitude, required this.timestamp});
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<_Visit> _visits = [];
  bool _saving = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _captureVisit() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (image == null) return;

      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
            position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          }
        }
      } catch (_) {}

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'visit_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedImage = await File(image.path).copy('${directory.path}/$fileName');

      final visit = _Visit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: savedImage.path,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        timestamp: DateTime.now(),
      );

      setState(() => _visits.insert(0, visit));

      if (AppConfig.hasSupabase) {
        try {
          final client = Supabase.instance.client;
          await client.from('heritage_visits').insert({
            'user_id': client.auth.currentUser?.id,
            'image_path': savedImage.path,
            'latitude': visit.latitude,
            'longitude': visit.longitude,
            'visited_at': visit.timestamp.toIso8601String(),
          });
        } catch (_) {}
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save visit. Please try again.')));
      }
    }
  }

  Future<void> _uploadToSupabase(_Visit visit) async {
    if (!AppConfig.hasSupabase) return;
    setState(() => _saving = true);
    try {
      final client = Supabase.instance.client;
      final bytes = await File(visit.imagePath).readAsBytes();
      final fileName = 'heritage_visits/${visit.id}${path.extension(visit.imagePath)}';
      await client.storage.from('heritage-media').uploadBinary(fileName, bytes);
      await client.from('heritage_visits').insert({
        'user_id': client.auth.currentUser?.id,
        'image_path': fileName,
        'latitude': visit.latitude,
        'longitude': visit.longitude,
        'visited_at': visit.timestamp.toIso8601String(),
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')),
                    const Text('Heritage Cam', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 22)),
                    _round(Icons.info_outline, () {}),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 260,
                  decoration: BoxDecoration(color: const Color(0xFF1A1311), borderRadius: BorderRadius.circular(24), border: Border.all(color: HeritageColors.orange.withValues(alpha:0.20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 80, height: 80, decoration: BoxDecoration(color: HeritageColors.orange.withValues(alpha:0.10), shape: BoxShape.circle), child: Icon(Icons.camera_alt, color: HeritageColors.orange, size: 36)),
                      const SizedBox(height: 16),
                      Text(_visits.isEmpty ? 'Capture your heritage journey' : '${_visits.length} visit${_visits.length == 1 ? '' : 's'} captured', style: const TextStyle(color: HeritageColors.cream, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Tap below to take a photo at a heritage site', style: TextStyle(color: Colors.white.withValues(alpha:0.60), fontSize: 13)),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _saving ? null : _captureVisit,
                        style: FilledButton.styleFrom(backgroundColor: HeritageColors.orange, foregroundColor: HeritageColors.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: Text(_saving ? 'Saving...' : 'Take Photo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_visits.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Visits', style: TextStyle(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(onPressed: () => setState(() => _visits.clear()), icon: const Icon(Icons.delete_outline, size: 18), label: const Text('Clear')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._visits.map((visit) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: Colors.white.withValues(alpha:0.08)), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(visit.imagePath), width: 72, height: 72, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Heritage Visit', style: TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${visit.latitude.toStringAsFixed(4)}, ${visit.longitude.toStringAsFixed(4)}', style: const TextStyle(color: Color(0x99FEFAE0), fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(visit.timestamp.toLocal().toString().substring(0, 19), style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
                          ]),
                        ),
                        if (AppConfig.hasSupabase)
                          IconButton(onPressed: () => _uploadToSupabase(visit), icon: const Icon(Icons.cloud_upload_outlined, color: HeritageColors.orange, size: 20)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
            const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 2)),
          ],
        ),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: Colors.white.withValues(alpha:0.10)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));
}

