// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

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

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final List<_Visit> _visits = [];
  bool _saving = false;
  bool _flashOn = false;
  bool _isGridView = false;
  late final AnimationController _cameraController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

  @override
  void initState() {
    super.initState();
    _cameraController.forward();
  }

  @override
  void dispose() {
    _cameraController.dispose();
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
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
            );
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
      if (mounted) _showSuccessSnack('Visit captured successfully!');
      if (AppConfig.hasSupabase) {
        _uploadToSupabase(visit);
      }
    } catch (_) {
      if (mounted) _showErrorSnack('Failed to capture visit. Please try again.');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
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
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
            );
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
      if (mounted) _showSuccessSnack('Photo added to visits!');
      if (AppConfig.hasSupabase) {
        _uploadToSupabase(visit);
      }
    } catch (_) {
      if (mounted) _showErrorSnack('Failed to add photo. Please try again.');
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
      if (mounted) _showSuccessSnack('Synced to cloud');
    } catch (_) {
      if (mounted) _showErrorSnack('Failed to sync. Will retry later.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSuccessSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: const Color(0xFF52B788), behavior: SnackBarBehavior.floating));
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: const Color(0xFFE76F51), behavior: SnackBarBehavior.floating));
  }

  Future<void> _clearAllVisits() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF29261E),
        title: const Text('Clear All Visits?', style: TextStyle(color: HeritageColors.cream)),
        content: const Text('This will remove all captured visits locally. This action cannot be undone.', style: TextStyle(color: Color(0x99FFFFFF))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Color(0x99FFFFFF)))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: Color(0xFFE76F51), fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _visits.clear());
      _showSuccessSnack('All visits cleared');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildCameraCard(),
                const SizedBox(height: 16),
                if (_visits.isNotEmpty) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${_visits.length} Visit${_visits.length == 1 ? '' : 's'}', style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(children: [
                      IconButton(onPressed: () => setState(() => _isGridView = !_isGridView), icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view_outlined, color: HeritageColors.orange, size: 20)),
                      TextButton.icon(onPressed: _clearAllVisits, icon: const Icon(Icons.delete_outline, size: 16), label: const Text('Clear', style: TextStyle(fontSize: 12))),
                    ]),
                  ]),
                  const SizedBox(height: 12),
                  _isGridView ? _buildGridView() : _buildListView(),
                ] else ...[
                  const SizedBox(height: 40),
                  _buildEmptyState(),
                ],
              ],
            ),
            if (_saving)
              Positioned(top: 16, left: 20, right: 20, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF29261E), borderRadius: BorderRadius.circular(12)), child: const Row(children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: HeritageColors.orange)), SizedBox(width: 12), Text('Syncing to cloud...', style: TextStyle(color: HeritageColors.cream))]))),
            const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/home')),
      Text('Heritage Cam', style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.w600)),
      _round(Icons.info_outline, () => _showInfoDialog()),
    ]);
  }

  Widget _buildCameraCard() {
    return ScaleTransition(scale: _cameraController, child: Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [HeritageColors.orange.withValues(alpha: 0.1), HeritageColors.orange.withValues(alpha: 0.02)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 90, height: 90, decoration: BoxDecoration(color: HeritageColors.orange.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(Icons.camera_alt, color: HeritageColors.orange, size: 40)),
        const SizedBox(height: 16),
        Text(_visits.isEmpty ? 'Capture your journey' : '${_visits.length} visit${_visits.length == 1 ? '' : 's'} logged', style: TextStyle(color: HeritageColors.cream, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Document every heritage site you visit', style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12)),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _CameraActionButton(icon: Icons.camera_alt, label: 'Camera', onTap: _captureVisit),
          const SizedBox(width: 16),
          _CameraActionButton(icon: Icons.photo_library, label: 'Gallery', onTap: _pickFromGallery),
          const SizedBox(width: 16),
          _CameraActionButton(icon: Icons.flash_on, label: 'Flash', onTap: () => setState(() => _flashOn = !_flashOn), active: _flashOn),
        ]),
      ]),
    ));
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.04))),
      child: Column(children: [
        Icon(Icons.photo_camera_outlined, size: 48, color: Colors.white.withValues(alpha: 0.2)),
        const SizedBox(height: 16),
        Text('No visits yet', style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Start capturing heritage sites to build your travel journal', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildListView() {
    return Column(children: _visits.map((visit) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFF17140F), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: InkWell(onTap: () => _showVisitDetail(visit), borderRadius: BorderRadius.circular(16), child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(visit.imagePath), width: 64, height: 64, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Heritage Visit', style: TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Icon(Icons.public, size: 12, color: Colors.white.withValues(alpha: 0.4)),
              Text('${visit.latitude.toStringAsFixed(3)}, ${visit.longitude.toStringAsFixed(3)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
            ]),
            const SizedBox(height: 4),
            Text(visit.timestamp.toLocal().toString().substring(0, 19), style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
          ])),
          if (AppConfig.hasSupabase)
            IconButton(onPressed: () => _uploadToSupabase(visit), icon: Icon(_isVisitUploaded(visit) ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined, color: HeritageColors.orange, size: 18)),
          IconButton(onPressed: () => _showDeleteConfirm(visit), icon: const Icon(Icons.delete_outline, color: Color(0xFFE76F51), size: 18)),
        ]),
      )),
    )).toList());
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _visits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
      itemBuilder: (context, index) => _GridVisitCard(visit: _visits[index], onTap: () => _showVisitDetail(_visits[index]), onDelete: () => _showDeleteConfirm(_visits[index])),
    );
  }

  void _showVisitDetail(_Visit visit) {
    showDialog(context: context, builder: (context) => Dialog(
      backgroundColor: const Color(0xFF29261E),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(visit.imagePath), width: double.infinity, height: 280, fit: BoxFit.cover)),
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(children: [
            Icon(Icons.location_on, size: 16, color: HeritageColors.orange),
            const SizedBox(width: 6),
            Expanded(child: Text('${visit.latitude.toStringAsFixed(5)}, ${visit.longitude.toStringAsFixed(5)}', style: const TextStyle(color: HeritageColors.cream, fontSize: 13))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.access_time, size: 14, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(width: 6),
            Text(visit.timestamp.toLocal().toString().substring(0, 19), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Color(0x99FFFFFF)))),
            if (AppConfig.hasSupabase) ElevatedButton.icon(onPressed: () { _uploadToSupabase(visit); Navigator.pop(context); }, icon: const Icon(Icons.cloud_upload_outlined, size: 16), label: const Text('Upload'), style: ElevatedButton.styleFrom(backgroundColor: HeritageColors.orange, foregroundColor: HeritageColors.background)),
          ]),
        ])),
      ]),
    ));
  }

  void _showDeleteConfirm(_Visit visit) {
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF29261E),
      title: const Text('Delete Visit?', style: TextStyle(color: HeritageColors.cream)),
      content: const Text('This will permanently remove this visit from your journal.', style: TextStyle(color: Color(0x99FFFFFF))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0x99FFFFFF)))),
        TextButton(onPressed: () { setState(() => _visits.removeWhere((v) => v.id == visit.id)); Navigator.pop(context); _showSuccessSnack('Visit deleted'); }, child: const Text('Delete', style: TextStyle(color: Color(0xFFE76F51), fontWeight: FontWeight.bold))),
      ],
    ));
  }

  void _showInfoDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF29261E),
      title: Text('Heritage Cam', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display')),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Document your heritage journey', style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Take photos at heritage sites and automatically log location and timestamp. Sync to cloud when connected.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.5)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it', style: TextStyle(color: HeritageColors.orange)))],
    ));
  }

  bool _isVisitUploaded(_Visit visit) {
    return visit.imagePath.contains('heritage_visits/');
  }

  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white.withValues(alpha: 0.08)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 18)));
}

class _CameraActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _CameraActionButton({required this.icon, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? HeritageColors.orange.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? HeritageColors.orange.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(children: [
        Icon(icon, color: active ? HeritageColors.orange : Colors.white.withValues(alpha: 0.7), size: 16),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: active ? HeritageColors.orange : Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ));
  }
}

class _GridVisitCard extends StatelessWidget {
  final _Visit visit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GridVisitCard({required this.visit, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
        child: Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(visit.imagePath), width: double.infinity, height: double.infinity, fit: BoxFit.cover)),
          Positioned(top: 8, right: 8, child: InkWell(onTap: onDelete, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFF29261E).withValues(alpha: 0.8), shape: BoxShape.circle), child: const Icon(Icons.delete_outline, color: Color(0xFFE76F51), size: 14))),
          Positioned(bottom: 8, left: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF29261E).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(8)), child: Text(visit.timestamp.toLocal().toString().substring(0, 10), style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.8), fontSize: 10)))),
        ]),
      ),
    );
  }
}
