// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

// ── Data model ───────────────────────────────────────────────────────────────
class _Visit {
  final String id;
  String imagePath;
  double latitude;
  double longitude;
  DateTime timestamp;
  String title;
  String notes;
  bool uploaded;

  _Visit({
    required this.id,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.title = 'Heritage Visit',
    this.notes = '',
    this.uploaded = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        'title': title,
        'notes': notes,
        'uploaded': uploaded,
      };

  factory _Visit.fromJson(Map<String, dynamic> j) => _Visit(
        id: j['id'] as String,
        imagePath: j['imagePath'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        timestamp: DateTime.parse(j['timestamp'] as String),
        title: j['title'] as String? ?? 'Heritage Visit',
        notes: j['notes'] as String? ?? '',
        uploaded: j['uploaded'] as bool? ?? false,
      );
}

// ── Screen ───────────────────────────────────────────────────────────────────
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  final List<_Visit> _visits = [];
  bool _saving = false;
  bool _isGridView = false;
  bool _loadingVisits = true;

  late final AnimationController _animController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  )..forward();

  static const _kJournalFile = 'heritage_journal.json';

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Persistence ──────────────────────────────────────────────────────────
  Future<File> _journalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_kJournalFile');
  }

  Future<void> _loadVisits() async {
    try {
      final file = await _journalFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        final list = jsonDecode(raw) as List<dynamic>;
        final visits = <_Visit>[];
        for (final item in list) {
          final v = _Visit.fromJson(item as Map<String, dynamic>);
          // Only keep visits with existing image files
          if (await File(v.imagePath).exists()) {
            visits.add(v);
          }
        }
        if (mounted) setState(() => _visits.addAll(visits));
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingVisits = false);
  }

  Future<void> _saveVisitsLocally() async {
    try {
      final file = await _journalFile();
      final data = jsonEncode(_visits.map((v) => v.toJson()).toList());
      await file.writeAsString(data);
    } catch (_) {}
  }

  // ── Location helper ──────────────────────────────────────────────────────
  Future<Position?> _getLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      return null;
    }
  }

  // ── Capture ──────────────────────────────────────────────────────────────
  Future<void> _captureVisit({bool fromGallery = false}) async {
    try {
      final xfile = await _picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 88,
        maxWidth: 2048,
      );
      if (xfile == null) return;

      final position = await _getLocation();
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'visit_${DateTime.now().millisecondsSinceEpoch}${p.extension(xfile.path)}';
      final saved = await File(xfile.path).copy('${dir.path}/$fileName');

      final visit = _Visit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: saved.path,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        timestamp: DateTime.now(),
      );

      setState(() => _visits.insert(0, visit));
      await _saveVisitsLocally();
      HapticFeedback.mediumImpact();

      if (mounted) _snack('📸 Saved to device! Add a note below.', isError: false);

      // Open note editor immediately after capture
      if (mounted) await _openNoteEditor(visit);

      // Sync to cloud
      if (AppConfig.hasSupabase) _syncToCloud(visit);
    } catch (e) {
      if (mounted) _snack('Could not capture visit. Please try again.', isError: true);
    }
  }

  // ── Cloud sync ───────────────────────────────────────────────────────────
  Future<void> _syncToCloud(_Visit visit) async {
    if (!AppConfig.hasSupabase) return;
    setState(() => _saving = true);
    try {
      final client = Supabase.instance.client;
      final bytes = await File(visit.imagePath).readAsBytes();
      final ext = p.extension(visit.imagePath);
      final storageKey = 'heritage_visits/${visit.id}$ext';

      await client.storage.from('heritage-media').uploadBinary(storageKey, bytes);
      await client.from('heritage_visits').upsert({
        'id': visit.id,
        'user_id': client.auth.currentUser?.id,
        'image_path': storageKey,
        'latitude': visit.latitude,
        'longitude': visit.longitude,
        'visited_at': visit.timestamp.toIso8601String(),
        'title': visit.title,
        'notes': visit.notes,
      });

      visit.uploaded = true;
      await _saveVisitsLocally();
      if (mounted) {
        setState(() {});
        _snack('Synced to cloud ☁️', isError: false);
      }
    } catch (_) {
      if (mounted) _snack('Cloud sync failed. Saved locally.', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Note editor ──────────────────────────────────────────────────────────
  Future<void> _openNoteEditor(_Visit visit) async {
    final titleCtrl = TextEditingController(text: visit.title);
    final notesCtrl = TextEditingController(text: visit.notes);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1714),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: HeritageColors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: HeritageColors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Notes',
                    style: GoogleFonts.plusJakartaSans(
                      color: HeritageColors.cream,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _NoteField(
                controller: titleCtrl,
                hint: 'Visit title (e.g. Sigiriya Rock)',
                icon: Icons.title_rounded,
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              _NoteField(
                controller: notesCtrl,
                hint: 'Write your experience, observations, or memories here...',
                icon: Icons.notes_rounded,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Skip', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        visit.title = titleCtrl.text.trim().isEmpty ? 'Heritage Visit' : titleCtrl.text.trim();
                        visit.notes = notesCtrl.text.trim();
                        _saveVisitsLocally();
                        setState(() {});
                        Navigator.pop(ctx);
                        _snack('Notes saved to device ✓', isError: false);
                        if (AppConfig.hasSupabase && visit.uploaded) {
                          _syncToCloud(visit);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HeritageColors.orange,
                        foregroundColor: const Color(0xFF1A0F05),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Save Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    titleCtrl.dispose();
    notesCtrl.dispose();
  }

  // ── Visit detail sheet ───────────────────────────────────────────────────
  void _openVisitDetail(_Visit visit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1714),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Image
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(visit.imagePath),
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            visit.title,
                            style: GoogleFonts.plusJakartaSans(
                              color: HeritageColors.cream,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (visit.uploaded)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF52B788).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF52B788).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.cloud_done_outlined, color: Color(0xFF52B788), size: 13),
                                SizedBox(width: 4),
                                Text('Synced', style: TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(Icons.location_on_outlined, '${visit.latitude.toStringAsFixed(5)}, ${visit.longitude.toStringAsFixed(5)}'),
                    const SizedBox(height: 6),
                    _InfoRow(Icons.access_time_rounded, _formatDate(visit.timestamp)),
                    if (visit.notes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.notes_rounded, color: HeritageColors.orange, size: 16),
                                SizedBox(width: 6),
                                Text('My Notes', style: TextStyle(color: HeritageColors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              visit.notes,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14, height: 1.55),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () { Navigator.pop(ctx); _openNoteEditor(visit); },
                            icon: const Icon(Icons.edit_note_rounded, size: 18),
                            label: const Text('Edit Notes'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: HeritageColors.cream,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (AppConfig.hasSupabase && !visit.uploaded)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () { Navigator.pop(ctx); _syncToCloud(visit); },
                              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                              label: const Text('Sync'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HeritageColors.orange,
                                foregroundColor: const Color(0xFF1A0F05),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        if (!AppConfig.hasSupabase || visit.uploaded)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () { _deleteVisit(visit); Navigator.pop(ctx); },
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE76F51).withValues(alpha: 0.15),
                                foregroundColor: const Color(0xFFE76F51),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteVisit(_Visit visit) {
    setState(() => _visits.removeWhere((v) => v.id == visit.id));
    _saveVisitsLocally();
    _snack('Visit removed', isError: false);
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFE76F51) : const Color(0xFF52B788),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final time = '${local.hour.toString().padLeft(2,'0')}:${local.minute.toString().padLeft(2,'0')}';
    return '${local.day} ${months[local.month - 1]} ${local.year}  ·  $time';
  }

  // ── UI ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C0A),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildCaptureCard()),
                if (_loadingVisits)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator(color: HeritageColors.orange, strokeWidth: 2)),
                    ),
                  )
                else if (_visits.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else ...[
                  SliverToBoxAdapter(child: _buildListHeader()),
                  _isGridView ? _buildGridSliver() : _buildListSliver(),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            if (_saving)
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: HeritageColors.orange)),
                      SizedBox(width: 12),
                      Text('Syncing to cloud...', style: TextStyle(color: HeritageColors.cream, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Icon(Icons.arrow_back, color: HeritageColors.cream, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heritage Cam',
                  style: GoogleFonts.plusJakartaSans(
                    color: HeritageColors.cream,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_visits.length} visit${_visits.length == 1 ? '' : 's'} in journal',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                ),
              ],
            ),
          ),
          if (AppConfig.hasSupabase)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF52B788).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF52B788).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.cloud_outlined, color: Color(0xFF52B788), size: 13),
                  SizedBox(width: 4),
                  Text('Cloud', style: TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptureCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HeritageColors.orange.withValues(alpha: 0.12),
            HeritageColors.orange.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: HeritageColors.orange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: HeritageColors.orange, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document Your Visit',
                      style: GoogleFonts.plusJakartaSans(
                        color: HeritageColors.cream,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Photo · GPS · Notes — saved to device always',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _CaptureButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () => _captureVisit(fromGallery: false),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CaptureButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _captureVisit(fromGallery: true),
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
      child: Row(
        children: [
          Text(
            'My Journal',
            style: GoogleFonts.plusJakartaSans(
              color: HeritageColors.cream.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(
              _isGridView ? Icons.view_agenda_outlined : Icons.grid_view_outlined,
              color: HeritageColors.orange,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Column(
          children: [
            Icon(Icons.photo_camera_outlined, size: 52, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            Text(
              'No visits yet',
              style: TextStyle(color: HeritageColors.cream.withValues(alpha: 0.7), fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture photos, add notes, and build\nyour personal heritage travel journal',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildListSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _VisitListTile(
          visit: _visits[i],
          onTap: () => _openVisitDetail(_visits[i]),
          onEdit: () => _openNoteEditor(_visits[i]),
          onDelete: () => _deleteVisit(_visits[i]),
        ),
        childCount: _visits.length,
      ),
    );
  }

  SliverGrid _buildGridSliver() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _VisitGridCard(
          visit: _visits[i],
          onTap: () => _openVisitDetail(_visits[i]),
          onDelete: () => _deleteVisit(_visits[i]),
        ),
        childCount: _visits.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _CaptureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _CaptureButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFFF4A261), Color(0xFFE9C46A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: isPrimary ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? const Color(0xFF1A0F05) : Colors.white.withValues(alpha: 0.8), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? const Color(0xFF1A0F05) : Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitListTile extends StatelessWidget {
  final _Visit visit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VisitListTile({
    required this.visit,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF17140F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(visit.imagePath),
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              visit.title,
                              style: const TextStyle(
                                color: HeritageColors.cream,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (visit.uploaded)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.cloud_done_outlined, size: 14, color: const Color(0xFF52B788).withValues(alpha: 0.7)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (visit.notes.isNotEmpty)
                        Text(
                          visit.notes,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 11, color: HeritageColors.orange.withValues(alpha: 0.6)),
                          const SizedBox(width: 3),
                          Text(
                            visit.latitude != 0 ? '${visit.latitude.toStringAsFixed(3)}, ${visit.longitude.toStringAsFixed(3)}' : 'Location not available',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
                          ),
                          const Spacer(),
                          // Always show a local-save badge
                          if (!visit.uploaded)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4A261).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone_android_outlined, size: 9, color: HeritageColors.orange.withValues(alpha: 0.7)),
                                  const SizedBox(width: 3),
                                  Text('On device', style: TextStyle(color: HeritageColors.orange.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          if (visit.uploaded)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF52B788).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.cloud_done_outlined, size: 9, color: Color(0xFF52B788)),
                                  SizedBox(width: 3),
                                  Text('Cloud + Device', style: TextStyle(color: Color(0xFF52B788), fontSize: 9, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_note_rounded, color: HeritageColors.orange.withValues(alpha: 0.7), size: 20),
                  tooltip: 'Edit notes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitGridCard extends StatelessWidget {
  final _Visit visit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _VisitGridCard({required this.visit, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(File(visit.imagePath), fit: BoxFit.cover),
            ),
            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
                  ),
                ),
                child: Text(
                  visit.title,
                  style: const TextStyle(color: HeritageColors.cream, fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Cloud badge
            if (visit.uploaded)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_done_outlined, color: Color(0xFF52B788), size: 13),
                ),
              ),
            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Color(0xFFE76F51), size: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _NoteField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: HeritageColors.cream, fontSize: 14, height: 1.5),
      cursorColor: HeritageColors.orange,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10, top: 14),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.35), size: 18),
        ),
        prefixIconConstraints: const BoxConstraints(),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HeritageColors.orange, width: 1.5),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: HeritageColors.orange.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        ),
      ],
    );
  }
}
