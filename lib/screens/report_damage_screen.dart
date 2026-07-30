import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../services/damage_report_repository.dart';
import '../services/location_service.dart';
import 'report_damage_image_widget.dart';
import 'report_damage_photo_uploader.dart';
import '../theme/heritage_colors.dart';

class ReportDamageScreen extends StatefulWidget {
  const ReportDamageScreen({super.key});

  @override
  State<ReportDamageScreen> createState() => _ReportDamageScreenState();
}

class _ReportDamageScreenState extends State<ReportDamageScreen> {
  String _type = 'Structural Cracks';
  bool _submitting = false;
  bool _fetchingGps = false;
  String _location = '';
  final _locationController = TextEditingController();
  final _details = TextEditingController();
  final _types = const [
    'Structural Cracks',
    'Vandalism',
    'Water Damage',
    'Erosion',
    'Vegetation Overgrowth',
    'Monument Degradation',
  ];
  final ImagePicker _picker = ImagePicker();
  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    if (_fetchingGps) return;
    setState(() => _fetchingGps = true);
    try {
      final position = await LocationService.getCurrentPosition(allowLastKnown: false);
      if (mounted) {
        if (position != null) {
          final locStr = LocationService.getNearestSiteDescription(position.latitude, position.longitude);
          setState(() {
            _location = locStr;
            _locationController.text = locStr;
            _fetchingGps = false;
          });
        } else {
          setState(() {
            _location = '';
            _locationController.clear();
            _fetchingGps = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live GPS unavailable. Please enter the location manually.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _location = '';
          _locationController.clear();
          _fetchingGps = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get live GPS. Please enter the location manually.')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1917),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Add Visual Evidence', style: TextStyle(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0x33E9C46A), shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Color(0xFFE9C46A))),
                title: const Text('Take Photo (Camera)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0x3352B788), shape: BoxShape.circle), child: const Icon(Icons.photo_library, color: Color(0xFF52B788))),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0x33F4A261), shape: BoxShape.circle), child: const Icon(Icons.photo_camera_back, color: Color(0xFFF4A261))),
                title: const Text('Attach Sample Evidence Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _photos.add('https://images.unsplash.com/photo-1586224372551-7f91854580bf?q=80&w=400&auto=format&fit=crop');
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
        if (images.isNotEmpty && mounted) {
          setState(() {
            _photos.addAll(images.map((img) => img.path));
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
        if (image != null && mounted) {
          setState(() => _photos.add(image.path));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access image: $e. You can attach sample photos instead.')),
        );
      }
    }
  }

  Future<List<String>> _uploadPhotos() async {
    if (_photos.isEmpty) return [];
    final client = Supabase.instance.client;
    final uploaded = <String>[];
    for (final photoPath in _photos) {
      try {
        uploaded.add(await uploadDamagePhoto(client, photoPath));
      } catch (_) {
        uploaded.add(photoPath);
      }
    }
    return uploaded;
  }

  Future<void> _submit() async {
    final text = _details.text.trim();
    if (text.isEmpty || _submitting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the damage observed before submitting.')),
      );
      return;
    }

    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a location or use live GPS before submitting.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      if (AppConfig.hasSupabase) {
        final uploadedPhotos = await _uploadPhotos();
        await DamageReportRepository(Supabase.instance.client).submit(
          damageType: _type,
          details: text,
          location: location,
          photos: uploadedPhotos,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF52B788)),
                SizedBox(width: 12),
                Expanded(child: Text('Damage report & photos submitted! Thank you 🎉')),
              ],
            ),
            backgroundColor: Color(0xFF1C1917),
            duration: Duration(seconds: 4),
          ),
        );
        setState(() {
          _photos.clear();
          _details.clear();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _round(Icons.arrow_back, () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  }),
                  const Text('Report Damage', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 22, fontWeight: FontWeight.bold)),
                  _round(Icons.history, () => Navigator.of(context).pushNamed('/profile')),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0x3352B788), Color(0x1152B788)]),
                  border: Border.all(color: const Color(0x6652B788)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Color(0xFF52B788), size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preserve Sri Lanka Heritage', style: TextStyle(color: Color(0xFF52B788), fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('Help protect monuments and historical structures', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _label('LOCATION'),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Use your live GPS location or edit it manually if needed.',
                  style: TextStyle(color: Color(0x80FFFFFF), fontSize: 12, height: 1.4),
                ),
              ),
              _card(
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF52B788)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Tap the GPS icon to fill your current location',
                          hintStyle: TextStyle(color: Color(0x4DFFFFFF)),
                        ),
                        style: const TextStyle(color: HeritageColors.cream, fontSize: 14),
                        onChanged: (v) => _location = v,
                      ),
                    ),
                    IconButton(
                      icon: _fetchingGps
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF52B788)))
                          : const Icon(Icons.my_location, color: Color(0xFF52B788), size: 20),
                      onPressed: _detectLocation,
                      tooltip: 'Get Current GPS Location',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _label('TYPE OF DAMAGE'),
              _card(
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _type,
                    dropdownColor: const Color(0xFF1C1917),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0x66FFFFFF)),
                    style: const TextStyle(color: HeritageColors.cream, fontSize: 14),
                    items: _types
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber, color: HeritageColors.orange, size: 20),
                                  const SizedBox(width: 12),
                                  Text(value),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _type = value!),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _label('VISUAL EVIDENCE (PHOTOS)'),
              SizedBox(
                height: 104,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: HeritageColors.orange.withValues(alpha: 0.08),
                          border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.40)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: HeritageColors.orange, size: 26),
                            SizedBox(height: 6),
                            Text('ADD PHOTO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ..._photos.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final path = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: _buildImageWidget(path),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => setState(() => _photos.removeAt(idx)),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(color: Color(0xB3000000), shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _label('DAMAGE DETAILS & OBSERVATIONS'),
              _card(
                TextField(
                  controller: _details,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Describe the damage level, affected area, and urgency...',
                    hintStyle: TextStyle(color: Color(0x4DFFFFFF)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: HeritageColors.orange,
                    disabledBackgroundColor: HeritageColors.orange.withValues(alpha: 0.50),
                    foregroundColor: HeritageColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    _submitting ? 'Submitting Report...' : 'Submit Damage Report',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildImageWidget(String path) {
    return ReportDamageImageWidget(path: path);
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)));
  Widget _card(Widget child) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white.withValues(alpha: 0.10)), borderRadius: BorderRadius.circular(20)), child: child);
  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), border: Border.all(color: Colors.white.withValues(alpha: 0.15)), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));
}
