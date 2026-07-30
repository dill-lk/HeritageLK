import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../services/offline_sri_lanka_map_cache.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class HeritageHeatmapPoint {
  final String siteName;
  final double lat;
  final double lon;
  final int intensity; // 1 to 10
  final String status;  // 'Thriving', 'Moderate', 'Endangered'

  const HeritageHeatmapPoint(this.siteName, this.lat, this.lon, this.intensity, this.status);
}

class HeritageHeatmapScreen extends StatefulWidget {
  const HeritageHeatmapScreen({super.key});

  @override
  State<HeritageHeatmapScreen> createState() => _HeritageHeatmapScreenState();
}

class _HeritageHeatmapScreenState extends State<HeritageHeatmapScreen> {
  static const _networkTileTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _fallbackTileTemplate = 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
  final MapController _mapController = MapController();
  String _selectedFilter = 'All';
  String? _offlineTileTemplate;
  bool _tilesReady = false;
  OfflineTileProgress? _tileProgress;
  StreamSubscription<OfflineTileProgress>? _progressSub;

  @override
  void initState() {
    super.initState();
    _prepareOfflineTiles();
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _prepareOfflineTiles() async {
    final template = await SriLankaOfflineMapCache.instance.ensureLocalTemplate();
    if (mounted) {
      setState(() => _offlineTileTemplate = template);
    }

    final alreadyReady = await SriLankaOfflineMapCache.instance.isTilesReady();
    if (alreadyReady && mounted) {
      setState(() => _tilesReady = true);
      return;
    }

    _progressSub = SriLankaOfflineMapCache.instance.progressStream.listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _tileProgress = progress;
          if (progress.isComplete) _tilesReady = true;
        });
      },
    );

    SriLankaOfflineMapCache.instance.warmSriLankaTiles();
  }

  // Heatmap density points for Heritage Sites across Sri Lanka
  static const List<HeritageHeatmapPoint> _points = [
    HeritageHeatmapPoint('Galle Dutch Fort', 6.0264, 80.217, 9, 'Thriving'),
    HeritageHeatmapPoint('Sigiriya Fortress', 7.9570, 80.7603, 10, 'Thriving'),
    HeritageHeatmapPoint('Tooth Relic Temple Kandy', 7.2936, 80.6415, 10, 'Thriving'),
    HeritageHeatmapPoint('Dambulla Cave Temple', 7.8566, 80.6483, 8, 'Thriving'),
    HeritageHeatmapPoint('Anuradhapura Ruins', 8.3354, 80.4037, 7, 'Endangered'),
    HeritageHeatmapPoint('Polonnaruwa Vatadage', 7.9472, 81.0016, 7, 'Endangered'),
    HeritageHeatmapPoint('Nine Arches Bridge Ella', 6.8767, 81.0608, 9, 'Thriving'),
    HeritageHeatmapPoint('Jaffna Fort', 9.6615, 80.0074, 5, 'Endangered'),
    HeritageHeatmapPoint('Koneswaram Trincomalee', 8.5857, 81.2342, 6, 'Moderate'),
    HeritageHeatmapPoint('Sinharaja Rainforest', 6.2111, 80.4044, 8, 'Endangered'),
    HeritageHeatmapPoint('Yapahuwa Citadel', 7.8285, 80.3204, 4, 'Endangered'),
    HeritageHeatmapPoint('Ritigala Reserve', 8.1186, 80.6583, 5, 'Endangered'),
    HeritageHeatmapPoint('Buduruwagala Statues', 6.6835, 81.0549, 4, 'Moderate'),
    HeritageHeatmapPoint('Mulkirigala Rock', 6.1611, 80.7719, 5, 'Moderate'),
    HeritageHeatmapPoint('Aukana Buddha', 8.0167, 80.5175, 6, 'Moderate'),
    HeritageHeatmapPoint('Kataragama Shrine', 6.4133, 81.3325, 8, 'Thriving'),
    HeritageHeatmapPoint('Dambadeniya Kingdom', 7.3639, 80.1458, 4, 'Endangered'),
    HeritageHeatmapPoint('Panduwasnuwara Ruins', 7.6681, 80.1772, 3, 'Endangered'),
    HeritageHeatmapPoint('Lankatilaka Kandy', 7.2694, 80.5638, 5, 'Moderate'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'All'
        ? _points
        : _points.where((p) => p.status == _selectedFilter).toList();

    final localTileTemplate = _offlineTileTemplate;
    final useOfflineTiles = _tilesReady && localTileTemplate != null && !kIsWeb;
    final tileTemplate = useOfflineTiles ? localTileTemplate : _networkTileTemplate;

    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Map Layer
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(7.8731, 80.7718), // Central Sri Lanka
                initialZoom: 7.8,
                minZoom: 6.5,
                maxZoom: 14.0,
              ),
              children: [
                TileLayer(
                  key: ValueKey<bool>(useOfflineTiles),
                  urlTemplate: useOfflineTiles ? tileTemplate : _networkTileTemplate,
                  subdomains: const [],
                  fallbackUrl: _fallbackTileTemplate,
                  tileProvider: useOfflineTiles
                      ? FileTileProvider()
                      : NetworkTileProvider(
                          headers: const {
                            'User-Agent': 'HeritageLK/1.0 (flutter_map; +https://github.com/fleaflet/flutter_map)',
                            'Accept': 'image/png,image/*;q=0.8',
                          },
                        ),
                  userAgentPackageName: 'com.heritage_lk.app',
                  maxNativeZoom: 18,
                  errorTileCallback: (tile, error, stackTrace) {
                    debugPrint('Heatmap tile error at ${tile.coordinates}: $error');
                  },
                ),
                // Glowing Heatmap Circles
                CircleLayer(
                  circles: filtered.expand((pt) {
                    final color = pt.status == 'Endangered'
                        ? const Color(0xFFE76F51) // Red/Orange
                        : pt.status == 'Moderate'
                            ? const Color(0xFFE9C46A) // Yellow
                            : const Color(0xFF52B788); // Green

                    return [
                      // Outer soft aura
                      CircleMarker(
                        point: LatLng(pt.lat, pt.lon),
                        radius: pt.intensity * 6.0,
                        color: color.withValues(alpha: 0.2),
                        borderStrokeWidth: 0,
                      ),
                      // Core bright glow
                      CircleMarker(
                        point: LatLng(pt.lat, pt.lon),
                        radius: pt.intensity * 2.5,
                        color: color.withValues(alpha: 0.55),
                        borderStrokeWidth: 1.5,
                        borderColor: Colors.white,
                      ),
                    ];
                  }).toList(),
                ),
                // Text marker labels
                MarkerLayer(
                  markers: filtered.map((pt) {
                    return Marker(
                      point: LatLng(pt.lat, pt.lon),
                      width: 120,
                      height: 40,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24, width: 0.5),
                          ),
                          child: Text(
                            pt.siteName,
                            style: const TextStyle(
                              color: HeritageColors.cream,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // Top Header & Filter Controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xF0100E0A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: HeritageColors.orange),
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HERITAGE HEATMAP',
                              style: GoogleFonts.playfairDisplay(
                                color: HeritageColors.cream,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Live Visitor Density & Endangered Site Alert',
                              style: TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Thriving', 'Moderate', 'Endangered'].map((filter) {
                        final isSel = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter, style: TextStyle(
                              color: isSel ? HeritageColors.background : HeritageColors.cream,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            )),
                            selected: isSel,
                            selectedColor: HeritageColors.orange,
                            backgroundColor: const Color(0xF01A1714),
                            onSelected: (_) => setState(() => _selectedFilter = filter),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            _buildDownloadBanner(),

            // Bottom Legend Overlay
            Positioned(
              bottom: 110,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xF0100E0A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LegendItem(color: Color(0xFF52B788), label: 'High Activity'),
                    _LegendItem(color: Color(0xFFE9C46A), label: 'Moderate'),
                    _LegendItem(color: Color(0xFFE76F51), label: 'Endangered / Needs Alert'),
                  ],
                ),
              ),
            ),

            const Align(
              alignment: Alignment.bottomCenter,
              child: HeritageBottomNav(currentIndex: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadBanner() {
    final progress = _tileProgress;
    if (progress == null || progress.isComplete) return const SizedBox.shrink();

    final pct = (progress.fraction * 100).toStringAsFixed(0);
    final label = progress.isFailed
        ? '⚠️ Map download paused — will retry'
        : '📥 Downloading offline map… $pct%';

    return Positioned(
      bottom: 165,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: progress.isComplete ? 0 : 1,
        duration: const Duration(milliseconds: 600),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xF0100E0A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.download_rounded,
                      color: HeritageColors.orange, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: HeritageColors.cream,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${progress.downloaded ~/ 1000}k / ${progress.total ~/ 1000}k',
                    style: TextStyle(
                      color: HeritageColors.cream.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.isFailed ? null : progress.fraction,
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress.isFailed
                        ? Colors.orange.shade700
                        : HeritageColors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: HeritageColors.cream, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
