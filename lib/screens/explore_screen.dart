import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/heritage_site.dart';
import '../services/heritage_api.dart';
import '../services/heritage_site_repository.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  final _api = HeritageApi();
  final _mapController = MapController();
  HeritageSite? _selected;
  String? _aiDetails;
  bool _detailsExpanded = true;
  String? _weatherTemp;
  String? _weatherWind;
  String _filterCategory = 'All';

  static const _allSites = [
    _SiteData('Galle Dutch Fort', 6.0264, 80.217, 'History', 'FREE', 'Entry to the Galle Dutch Fort itself is completely free for all visitors. You can walk the ramparts, visit the lighthouse, and explore the cobblestone streets without a ticket.'),
    _SiteData('Galle Lighthouse', 6.0249, 80.2195, 'History', 'FREE', 'A picturesque, historic lighthouse located inside the Galle Fort. While you cannot go inside, exploring the area around it is completely free.'),
    _SiteData('National Museum', 6.027, 80.2185, 'Knowledge', '300 LKR', 'Located inside the fort, this museum offers deep insights into the cultural history of Southern Sri Lanka. Entry is 300 LKR for foreign adults.'),
    _SiteData('Jungle Beach', 6.015, 80.237, 'Nature', 'FREE', 'A beautiful hidden beach near Galle. Access is free and it offers a relatively quiet swimming experience surrounded by forest.'),
    _SiteData('Sigiriya Rock Fortress', 7.957, 80.7603, 'History', r'$30 USD', 'An ancient rock fortress and palace ruin surrounded by an extensive network of gardens and reservoirs. A UNESCO World Heritage site.'),
    _SiteData('Temple of the Sacred Tooth Relic', 7.2936, 80.6415, 'History', '2000 LKR', 'A Buddhist temple in the city of Kandy, housing the relic of the tooth of the Buddha.'),
    _SiteData('Ruwanwelisaya', 8.35, 80.3965, 'History', 'Included in Anuradhapura pass', 'A stupa in Anuradhapura, considered one of the worlds tallest monuments and a sacred place of worship.'),
    _SiteData('Dambulla Cave Temple', 7.8566, 80.6483, 'History', '2000 LKR', 'The largest and best-preserved cave temple complex in Sri Lanka, boasting ancient Buddhist murals and statues.'),
    _SiteData('Yala National Park', 6.3686, 81.5165, 'Nature', r'~$35 USD', 'A huge area of forest, grassland and lagoons bordering the Indian Ocean, in southeast Sri Lanka. Famous for its leopards.'),
    _SiteData('Nine Arches Bridge', 6.8767, 81.0608, 'Nature', 'FREE', 'A picturesque colonial-era railway bridge in Demodara, near Ella. Famous for its magnificent architecture set amongst lush green tea fields.'),
    _SiteData("Adam's Peak (Sri Pada)", 6.8096, 80.4994, 'Nature', 'FREE', 'A tall conical mountain in central Sri Lanka, known for the "sacred footprint" near its summit.'),
    _SiteData('Polonnaruwa Vatadage', 7.9472, 81.0016, 'History', 'Included in Polonnaruwa pass', 'An ancient structure dating back to the Kingdom of Polonnaruwa. The best-preserved example of a vatadage in the country.'),
    _SiteData('Royal Botanical Gardens, Peradeniya', 7.2687, 80.5966, 'Nature', '3000 LKR', 'Renowned for its collection of orchids, including more than 4000 species of plants, spices, medicinal plants and palm trees.'),
    _SiteData('Horton Plains National Park', 6.8028, 80.8066, 'Nature', r'~$30 USD', 'A protected area in the central highlands covered by montane grassland and cloud forest.'),
    _SiteData('Mirissa Beach', 5.9483, 80.4572, 'Nature', 'FREE', 'A popular tourist destination known for its beautiful beach and whale watching.'),
    _SiteData('Pinnawala Elephant Orphanage', 7.3013, 80.3873, 'Nature', '3000 LKR', 'An orphanage, nursery and captive breeding ground for wild Asian elephants.'),
    _SiteData('Colombo Lotus Tower', 6.9271, 79.8588, 'Knowledge', r'$20 USD', 'A 350m-tall tower in Colombo, offering panoramic views of the city.'),
    _SiteData('Gangarama Temple', 6.9167, 79.858, 'History', '400 LKR', 'One of the most important temples in Colombo, blending modern architecture and cultural essence.'),
    _SiteData('Arugam Bay', 6.8427, 81.8266, 'Nature', 'FREE', 'A popular surfing destination on the southeast coast of Sri Lanka.'),
    _SiteData('Minneriya National Park', 8.041, 80.8523, 'Nature', r'~$25 USD', 'A national park famous for the "Gathering" of wild elephants during the dry season.'),
    _SiteData("St. Anthony's Shrine, Kochchikade", 6.9452, 79.854, 'History', 'FREE', 'A Roman Catholic church in the Archdiocese of Colombo and a national shrine.'),
    _SiteData('Jaffna Fort', 9.6615, 80.0074, 'History', 'FREE', 'A fort built by the Portuguese at Jaffna in 1618 under Phillippe de Oliveira following his invasion of Jaffna.'),
    _SiteData('Nallur Kandaswamy Temple', 9.6749, 80.0264, 'History', 'FREE', 'One of the most significant Hindu temples in the Jaffna District.'),
    _SiteData('Independence Memorial Hall', 6.9044, 79.8674, 'History', 'FREE', 'A national monument in Sri Lanka built for commemoration of the independence from British rule.'),
    _SiteData('Galle Face Green', 6.9234, 79.8447, 'Knowledge', 'FREE', 'A 5 hectare ocean-side urban park, which stretches for 500 m along the coast, in the heart of Colombo.'),
    _SiteData('Nuwara Eliya Post Office', 6.973, 80.7686, 'History', 'FREE', 'One of the oldest post offices in Sri Lanka, housed in a beautiful Tudor-style colonial building.'),
    _SiteData('Gregory Lake', 6.9582, 80.7725, 'Nature', '250 LKR', 'A prominent attraction in Nuwara Eliya, built in 1873 during the British period for relaxation.'),
    _SiteData('Ella Rock', 6.8647, 81.0483, 'Nature', 'FREE', 'A famous viewpoint offering panoramic views of the lush green valleys and mountains around Ella.'),
    _SiteData('Rawana Falls', 6.8407, 81.0543, 'Nature', 'FREE', 'A beautiful and popular waterfall in Ella, linked to the Hindu epic Ramayana.'),
    _SiteData('Yapahuwa Rock Fortress', 7.8285, 80.3204, 'History', r'$3 USD', 'Once a capital of Sri Lanka, this fortress features an iconic ornamental stairway that leads to the top.'),
    _SiteData('Koneswaram Temple', 9.6814, 80.1175, 'History', 'FREE', 'An ancient Hindu temple on a cliff overlooking Trincomalee harbour. One of the five sacred Iswarams of Shiva.'),
    _SiteData('Mihintale', 8.3486, 80.5896, 'History', 'FREE', 'Considered the cradle of Buddhism in Sri Lanka. Home to several ancient stupas and monastic ruins.'),
    _SiteData('Pidurangala Rock', 7.9636, 80.7565, 'Nature', r'$5 USD', 'A large rock formation offering panoramic views of Sigiriya and the surrounding jungle.'),
    _SiteData('Sinharaja Forest Reserve', 6.2111, 80.4044, 'Nature', r'~$35 USD', 'A UNESCO World Heritage Site and Sri Lanka\'s last viable primary tropical rainforest.'),
    _SiteData('Bentota Beach', 6.4226, 80.0019, 'Nature', 'FREE', 'A popular beach destination known for water sports and turtle hatcheries.'),
    _SiteData('Hikkaduwa Beach', 6.1427, 80.0983, 'Nature', 'FREE', 'Famous for its coral reefs, nightlife, and beachside restaurants.'),
    _SiteData('Pettah Market', 6.9374, 79.8576, 'Knowledge', 'FREE', 'A bustling open-air market in Colombo offering everything from spices to textiles.'),
    _SiteData('Viharamahadevi Park', 6.9167, 79.8608, 'Knowledge', 'FREE', 'A large public park in Colombo featuring a giant Buddha statue and seasonal blooms.'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  @override
  void dispose() {
    _search.dispose();
    _api.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadSites() async {
    if (!AppConfig.hasSupabase) return;
    try {
      final rows = await HeritageSiteRepository(Supabase.instance.client).listSites();
      if (mounted && rows.isNotEmpty) {
        // dynamic sites loaded if any
      }
    } catch (_) {
      if (mounted) {
        // handle error
      }
    }
  }

  Future<void> _select(_SiteData site) async {
    setState(() {
      _selected = HeritageSite(id: site.name.toLowerCase().replaceAll(' ', '-'), title: site.name, summary: site.aiOverview, locationName: 'Sri Lanka');
      _aiDetails = null;
      _weatherTemp = null;
      _weatherWind = null;
      _detailsExpanded = true;
    });
    _mapController.move(LatLng(site.lat, site.lon), 11.0);
    _loadWeather(site.lat, site.lon);
    _loadAiDetails(site.name);
  }

  Future<void> _loadWeather(double lat, double lon) async {
    try {
      final res = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final weather = data['current_weather'];
        if (mounted && weather != null) {
          setState(() {
            _weatherTemp = '${weather['temperature']}°C';
            _weatherWind = '${weather['windspeed']} km/h';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadAiDetails(String name) async {
    try {
      final details = await _api.siteDetails(name);
      final aiText = details['details']?.toString() ?? details['description']?.toString();
      if (mounted && aiText != null) setState(() => _aiDetails = aiText);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final filtered = _allSites.where((site) {
      final matchesSearch = q.isEmpty || site.name.toLowerCase().contains(q) || site.category.toLowerCase().contains(q);
      final matchesCategory = _filterCategory == 'All' || site.category == _filterCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    final current = _selected != null ? _allSites.firstWhere((s) => s.name == _selected!.title, orElse: () => _allSites[0]) : (filtered.isNotEmpty ? filtered[0] : _allSites[0]);

    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          _mapBackground(filtered, current),
          _topOverlay(q, filtered),
          _bottomInfoCard(current),
          _buildZoomControls(),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 1)),
        ]),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 16,
      bottom: 140,
      child: Column(children: [
        _zoomButton(Icons.add, () => _mapController.move(_mapController.camera.center, (_mapController.camera.zoom + 1).clamp(6.0, 18.0))),
        const SizedBox(height: 8),
        _zoomButton(Icons.remove, () => _mapController.move(_mapController.camera.center, (_mapController.camera.zoom - 1).clamp(6.0, 18.0))),
      ]),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xE61A1311), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha:0.10))), child: Icon(icon, color: HeritageColors.orange, size: 20)));
  }

  Widget _mapBackground(List<_SiteData> filtered, _SiteData current) {
    return Positioned.fill(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(current.lat, current.lon),
          initialZoom: 8.5,
          minZoom: 6.0,
          maxZoom: 18.0,
        ),
        children: [
           TileLayer(
             urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
             userAgentPackageName: 'com.heritage_lk.app',
           ),
          MarkerLayer(
            markers: filtered.map((site) {
              final isSelected = site.name == current.name;
              return Marker(
                point: LatLng(site.lat, site.lon),
                width: isSelected ? 48 : 36,
                height: isSelected ? 48 : 36,
                child: GestureDetector(
                  onTap: () => _select(site),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isSelected ? HeritageColors.orange : const Color(0xFF52B788),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
                      boxShadow: [
                        BoxShadow(
                          color: (isSelected ? HeritageColors.orange : const Color(0xFF52B788)).withValues(alpha:0.6),
                          blurRadius: isSelected ? 12 : 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        site.category == 'Nature' ? Icons.park : (site.category == 'History' ? Icons.account_balance : Icons.school),
                        color: Colors.white,
                        size: isSelected ? 24 : 18,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _topOverlay(String q, List<_SiteData> filtered) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(color: const Color(0xE61A1311), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.3), blurRadius: 12)]),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: HeritageColors.cream, fontSize: 15),
              decoration: InputDecoration(hintText: 'Search Heritage', hintStyle: const TextStyle(color: Color(0x99FEFAE0)), prefixIcon: const Icon(Icons.search, color: Color(0x99FEFAE0)), suffixIcon: _search.text.isNotEmpty ? IconButton(onPressed: () => setState(() => _search.clear()), icon: const Text('X', style: TextStyle(color: Color(0x99FEFAE0), fontWeight: FontWeight.bold))) : null, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
            ),
          ),
          if (q.isNotEmpty && filtered.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 260),
              decoration: BoxDecoration(color: const Color(0xF00F0C0A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha:0.05))),
              child: ListView.builder(shrinkWrap: true, itemCount: filtered.length, itemBuilder: (_, i) {
                final site = filtered[i];
                return InkWell(onTap: () { _select(site); setState(() => _search.clear()); }, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: Row(children: [const Icon(Icons.location_on, color: HeritageColors.orange, size: 16), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(site.name, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.bold)), Text(site.category.toUpperCase(), style: const TextStyle(color: Color(0x80FEFAE0), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))]))])));
              }),
            ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _filterChip('All', _filterCategory == 'All', () => setState(() => _filterCategory = 'All')),
            const SizedBox(width: 12),
            _filterChip('History', _filterCategory == 'History', () => setState(() => _filterCategory = 'History')),
            const SizedBox(width: 12),
            _filterChip('Nature', _filterCategory == 'Nature', () => setState(() => _filterCategory = 'Nature')),
          ]),
        ]),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xE61A1311), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withValues(alpha:0.05))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? HeritageColors.orange : Colors.white38, size: 14),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _bottomInfoCard(_SiteData site) {
    return Positioned(
      bottom: 108,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: const Color(0xF00F0C0A), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white.withValues(alpha:0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.4), blurRadius: 24)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${site.name} 🏰', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 4),
              Row(children: [Icon(Icons.public, color: Colors.green.shade400, size: 12), const SizedBox(width: 6), Text('UNESCO WORLD HERITAGE SITE', style: TextStyle(color: Colors.green.shade400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8))]),
            ])),
            GestureDetector(onTap: () => setState(() => _detailsExpanded = !_detailsExpanded), child: Container(width: 44, height: 44, decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha:0.05)), shape: BoxShape.circle), child: Icon(_detailsExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, color: Colors.white70, size: 22))),
          ]),
          if (_detailsExpanded) ...[
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _actionButton('Scan Site', HeritageColors.orange, () => Navigator.of(context).pushNamed('/scanner'))),
              const SizedBox(width: 12),
              _iconButton(Icons.refresh, HeritageColors.orange, () => _select(site)),
              const SizedBox(width: 12),
              _iconButton(Icons.flag, const Color(0xFFC084FC)),
            ]),
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white.withValues(alpha:0.05)),
            const SizedBox(height: 16),
            Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: HeritageColors.orange, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('AI QUICK INSIGHTS', style: TextStyle(color: HeritageColors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const Spacer(),
              if (_weatherTemp != null) Text('🌡️ $_weatherTemp  💨 ${_weatherWind ?? ""}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _detailPill(Icons.confirmation_number_outlined, site.ticketPrice),
              const SizedBox(width: 8),
              _detailPill(Icons.schedule, 'Open 24/7'),
            ]),
            const SizedBox(height: 12),
            Text(_aiDetails ?? site.aiOverview, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 14, height: 1.6)),
          ],
        ]),
      ),
    );
  }

  Widget _detailPill(IconData icon, String text) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: HeritageColors.orange, size: 12), const SizedBox(width: 6), Text(text, style: const TextStyle(color: HeritageColors.orange, fontSize: 11, fontWeight: FontWeight.bold))]));
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.camera_alt, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color color, [VoidCallback? onTap]) {
    return GestureDetector(onTap: onTap, child: Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: Colors.white.withValues(alpha:0.05)), borderRadius: BorderRadius.circular(20)), child: Icon(icon, color: color, size: 22)));
  }
}

class _SiteData {
  final String name;
  final double lat;
  final double lon;
  final String category;
  final String ticketPrice;
  final String aiOverview;
  const _SiteData(this.name, this.lat, this.lon, this.category, this.ticketPrice, this.aiOverview);
}

