import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../models/heritage_site.dart';
import '../services/heritage_api.dart';
import '../services/heritage_site_repository.dart';
import '../services/offline_sri_lanka_map_cache.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // OpenStreetMap is reliable and free — use it as the primary tile source.
  // CartoBasemaps dark is used only as a fallback (it requires the {r} suffix
  // stripped out and sometimes rate-limits anonymous requests).
  static const _networkTileTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _fallbackTileTemplate = 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';

  // Persistent HTTP client with connection keep-alive for tile fetching.
  // Reusing the same client avoids TLS handshake overhead on every tile.
  late final http.Client _tileHttpClient = _buildTileClient();

  static http.Client _buildTileClient() {
    if (kIsWeb) return http.Client();
    final httpClient = HttpClient()
      ..maxConnectionsPerHost = 8   // parallel tile fetches
      ..connectionTimeout = const Duration(seconds: 10)
      ..idleTimeout = const Duration(seconds: 30);
    return IOClient(httpClient);
  }

  final _search = TextEditingController();
  final _api = HeritageApi();
  final _mapController = MapController();
  HeritageSite? _selected;
  String? _aiDetails;
  bool _detailsExpanded = true;
  String? _weatherTemp;
  String? _weatherWind;
  final String _filterCategory = 'All';
  String? _offlineTileTemplate;
  bool _tilesReady = false; // true only when all tiles are confirmed on disk
  OfflineTileProgress? _tileProgress; // null = not yet started or already done
  StreamSubscription<OfflineTileProgress>? _progressSub;

  static const _allSites = [
    // ── UNESCO & Major Heritage ─────────────────────────────────────────────
    _SiteData('Galle Dutch Fort', 6.0264, 80.217, 'History', 'FREE', 'Entry to the Galle Dutch Fort itself is completely free for all visitors. You can walk the ramparts, visit the lighthouse, and explore the cobblestone streets without a ticket.'),
    _SiteData('Galle Lighthouse', 6.0249, 80.2195, 'History', 'FREE', 'A picturesque, historic lighthouse located inside the Galle Fort. While you cannot go inside, exploring the area around it is completely free.'),
    _SiteData('National Museum Galle', 6.027, 80.2185, 'Knowledge', '300 LKR', 'Located inside the fort, this museum offers deep insights into the cultural history of Southern Sri Lanka. Entry is 300 LKR for foreign adults.'),
    _SiteData('Sigiriya Rock Fortress', 7.957, 80.7603, 'History', r'$30 USD', 'An ancient rock fortress and palace ruin surrounded by an extensive network of gardens and reservoirs. A UNESCO World Heritage site built by King Kashyapa in 477 AD.'),
    _SiteData('Pidurangala Rock', 7.9636, 80.7565, 'Nature', r'$5 USD', 'A large rock formation offering panoramic views of Sigiriya and the surrounding jungle. A great, more affordable alternative to Sigiriya for sunrise views.'),
    _SiteData('Temple of the Sacred Tooth Relic', 7.2936, 80.6415, 'History', '2000 LKR', 'A Buddhist temple in the city of Kandy, housing the relic of the tooth of the Buddha. One of the holiest places of worship in the Buddhist world.'),
    _SiteData('Dambulla Cave Temple', 7.8566, 80.6483, 'History', '2000 LKR', 'The largest and best-preserved cave temple complex in Sri Lanka, boasting ancient Buddhist murals and statues spanning 5 caves. A UNESCO World Heritage Site.'),
    _SiteData('Ruwanwelisaya', 8.35, 80.3965, 'History', 'Included in Anuradhapura pass', 'A stupa in Anuradhapura, considered one of the world\'s tallest monuments. Built by King Dutugemunu around 140 BC, it stands 103m tall.'),
    _SiteData('Anuradhapura Sacred City', 8.3354, 80.4037, 'History', '5000 LKR combo', 'The first capital of Sri Lanka, with a civilisation spanning 1300 years. Home to some of the world\'s oldest stupas, monasteries and the sacred Sri Maha Bodhi tree.'),
    _SiteData('Polonnaruwa Vatadage', 7.9472, 81.0016, 'History', 'Included in Polonnaruwa pass', 'An ancient structure dating back to the Kingdom of Polonnaruwa. The best-preserved example of a vatadage in the country. The city flourished in the 11th–13th centuries.'),
    _SiteData('Mihintale', 8.3486, 80.5896, 'History', 'FREE', 'Considered the cradle of Buddhism in Sri Lanka. Missionary Mahinda introduced Buddhism to the king Devanampiya Tissa here in 247 BC. Home to ancient stupas and monastic ruins.'),
    _SiteData('Sinharaja Forest Reserve', 6.2111, 80.4044, 'Nature', r'~$35 USD', 'A UNESCO World Heritage Site and Sri Lanka\'s last viable primary tropical rainforest. Home to 50% of Sri Lanka\'s endemic species of mammals and butterflies.'),
    _SiteData('Yapahuwa Rock Fortress', 7.8285, 80.3204, 'History', r'$3 USD', 'Once a capital of Sri Lanka, this fortress features an iconic ornamental stairway that leads to the top. The Tooth Relic was kept here briefly in the 13th century.'),
    // ── Nature & Wildlife ───────────────────────────────────────────────────
    _SiteData('Yala National Park', 6.3686, 81.5165, 'Nature', r'~$35 USD', 'A huge area of forest, grassland and lagoons bordering the Indian Ocean. Sri Lanka\'s most-visited park and famous for having the world\'s highest density of leopards.'),
    _SiteData('Minneriya National Park', 8.041, 80.8523, 'Nature', r'~$25 USD', 'Famous for the "Gathering" — one of Asia\'s greatest wildlife spectacles, where hundreds of wild elephants converge on the ancient reservoir during the dry season (Jun–Oct).'),
    _SiteData('Wilpattu National Park', 8.3988, 80.0117, 'Nature', r'~$25 USD', 'Sri Lanka\'s largest national park, known for its "Villus" — natural lakes that attract wildlife including leopards, sloth bears, crocodiles and elephants.'),
    _SiteData('Udawalawe National Park', 6.4396, 80.8793, 'Nature', r'~$25 USD', 'A park created around the Uda Walawe reservoir, famous for its large population of wild Asian elephants. Over 600 elephants roam freely — incredible year-round.'),
    _SiteData('Horton Plains National Park', 6.8028, 80.8066, 'Nature', r'~$30 USD', 'A protected area in the central highlands covered by montane grassland and cloud forest, home to World\'s End — a sheer cliff with a 880m drop offering dramatic views.'),
    _SiteData('Bundala National Park', 6.1976, 81.2235, 'Nature', r'~$20 USD', 'A UNESCO biosphere reserve and a Ramsar Convention wetland. Home to five species of sea turtles and thousands of migratory birds including flamingos.'),
    _SiteData('Wasgamuwa National Park', 7.7636, 80.8968, 'Nature', r'~$20 USD', 'One of the most important elephant conservation areas in Sri Lanka with over 150 elephants. Less crowded than other parks — a great off-the-beaten-path safari option.'),
    _SiteData('Pinnawala Elephant Orphanage', 7.3013, 80.3873, 'Nature', '3000 LKR', 'An orphanage, nursery and captive breeding ground for wild Asian elephants. Watch the herd bathe in the Maha Oya river — a unique and unforgettable experience.'),
    _SiteData('Royal Botanical Gardens, Peradeniya', 7.2687, 80.5966, 'Nature', '3000 LKR', 'Renowned for its collection of orchids, including more than 4000 species of plants, spices, medicinal plants and palm trees. A stunning 147-acre garden near Kandy.'),
    // ── Beaches ─────────────────────────────────────────────────────────────
    _SiteData('Mirissa Beach', 5.9483, 80.4572, 'Nature', 'FREE', 'A popular tourist destination known for its beautiful crescent beach and world-class whale watching (Nov–Apr). Spot blue whales and sperm whales up close.'),
    _SiteData('Unawatuna Beach', 6.0101, 80.249, 'Nature', 'FREE', 'One of the most famous beaches near Galle, known for calm turquoise waters, snorkelling, coral reefs and a vibrant restaurant scene.'),
    _SiteData('Arugam Bay', 6.8427, 81.8266, 'Nature', 'FREE', 'A globally-ranked surf destination on the southeast coast of Sri Lanka. The main point break is one of the top 10 surf spots in the world (May–Oct).'),
    _SiteData('Bentota Beach', 6.4226, 80.0019, 'Nature', 'FREE', 'A popular beach destination on the west coast known for water sports (jet skiing, kite surfing, windsurfing), turtle hatcheries and luxury resorts.'),
    _SiteData('Hikkaduwa Beach', 6.1427, 80.0983, 'Nature', 'FREE', 'Famous for its coral reefs (ideal for snorkelling), vibrant nightlife, beachside restaurants and a laid-back surfer vibe. A classic Sri Lanka beach town.'),
    _SiteData('Nilaveli Beach', 8.7205, 81.2075, 'Nature', 'FREE', 'An unspoiled, pristine beach on the east coast near Trincomalee. Crystal clear blue waters with virtually no crowds — one of Sri Lanka\'s best-kept secrets.'),
    _SiteData('Tangalle Beach', 6.0266, 80.7948, 'Nature', 'FREE', 'A series of beautiful bays on the south coast, popular for sea turtle nesting. The wide, wild beach has a rugged, undeveloped feel great for relaxation.'),
    _SiteData('Passikudah Bay', 7.9311, 81.5583, 'Nature', 'FREE', 'A sheltered, shallow bay on the east coast with calm, crystal-clear water stretching hundreds of metres — perfect for wading and snorkelling.'),
    _SiteData('Jungle Beach Galle', 6.015, 80.237, 'Nature', 'FREE', 'A beautiful hidden beach near Galle, accessible via a short jungle walk. A relatively quiet swimming spot surrounded by forest — a local favourite.'),
    // ── Hill Country & Waterfalls ───────────────────────────────────────────
    _SiteData('Nine Arches Bridge', 6.8767, 81.0608, 'Nature', 'FREE', 'A picturesque colonial-era railway bridge in Demodara, near Ella. Built in 1921 entirely from brick, cement and stone — no steel used. Famous for train crossings.'),
    _SiteData('Ella Rock', 6.8647, 81.0483, 'Nature', 'FREE', 'A famous hike offering panoramic views of the lush green valleys and mountains around Ella. The 3–4 hour round trip through tea estates is one of Sri Lanka\'s best hikes.'),
    _SiteData('Rawana Falls', 6.8407, 81.0543, 'Nature', 'FREE', 'A beautiful and popular waterfall in Ella, one of the widest falls in Sri Lanka. Linked to the Hindu epic Ramayana — said to be where Ravana hid Sita.'),
    _SiteData('Dunhinda Falls', 7.0542, 81.0565, 'Nature', '150 LKR', 'One of the most spectacular waterfalls in Sri Lanka near Badulla. Reached via a 1.5km jungle walk. The mist and roar of the 64m fall is extraordinary.'),
    _SiteData('Baker Falls', 6.7982, 80.793, 'Nature', 'Included in Horton Plains entry', 'A stunning 20m waterfall within Horton Plains National Park, named after British explorer Sir Samuel Baker. Best visited after World\'s End on the loop trail.'),
    _SiteData("Adam's Peak (Sri Pada)", 6.8096, 80.4994, 'Nature', 'FREE (pilgrimage season)', 'A tall conical mountain known for the "sacred footprint" near its summit. Pilgrims climb 5500 steps overnight to witness the stunning sunrise and the famous triangular shadow.'),
    _SiteData('Gregory Lake Nuwara Eliya', 6.9582, 80.7725, 'Nature', '250 LKR', 'A prominent attraction in Nuwara Eliya, built in 1873 during the British period. Perfect for boat rides, cycling and picnics surrounded by misty hills and tea estates.'),
    _SiteData('Knuckles Mountain Range', 7.4167, 80.7833, 'Nature', 'FREE (some trails)', 'A UNESCO-listed misty mountain wilderness with over 34 peaks, waterfalls, caves and ancient villages. Named for its knuckle-like silhouette when viewed from Kandy.'),
    _SiteData('Nuwara Eliya Post Office', 6.973, 80.7686, 'History', 'FREE', 'One of the oldest post offices in Sri Lanka, housed in a beautiful Tudor-style colonial building. The whole town of Nuwara Eliya feels like a little piece of England.'),
    // ── Colombo & West ──────────────────────────────────────────────────────
    _SiteData('Colombo Lotus Tower', 6.9271, 79.8588, 'Knowledge', r'$20 USD', 'A 350m-tall communications tower in Colombo — the tallest self-supporting structure in South Asia. Offers panoramic 360° city views from the observation deck.'),
    _SiteData('Gangarama Temple', 6.9167, 79.858, 'History', '400 LKR', 'One of the most important temples in Colombo, blending Sri Lankan, Thai, Indian and Chinese architecture. Houses a fascinating museum of Buddha statues and rare artefacts.'),
    _SiteData('Galle Face Green', 6.9234, 79.8447, 'Knowledge', 'FREE', 'A 5-hectare ocean-side urban park stretching 500m along the coast. A beloved gathering place for families, kite flyers and street food lovers at sunset.'),
    _SiteData('Independence Memorial Hall', 6.9044, 79.8674, 'History', 'FREE', 'A national monument built for commemoration of Sri Lanka\'s independence from British rule in 1948. Modelled on the Audience Hall of the Kandyan kings.'),
    _SiteData('Viharamahadevi Park', 6.9167, 79.8608, 'Knowledge', 'FREE', 'A large public park in Colombo featuring a 9m giant Buddha statue and seasonal blooms. Named after the heroic Queen Viharamahadevi, mother of King Dutugemunu.'),
    _SiteData('Pettah Market', 6.9374, 79.8576, 'Knowledge', 'FREE', 'A bustling open-air market in the heart of Colombo offering everything from fresh spices and textiles to electronics. A sensory overload in the best possible way.'),
    _SiteData('Kelaniya Raja Maha Vihara', 7.0028, 79.9162, 'History', 'FREE', 'One of the most sacred Buddhist temples in Sri Lanka. The Buddha himself is said to have visited this site 2,500 years ago. Famous for Duruthu Perahera in January.'),
    _SiteData('St. Anthony\'s Shrine Kochchikade', 6.9452, 79.854, 'History', 'FREE', 'A revered national Catholic shrine in Colombo, famous for miraculous healings and visited by people of all faiths every Tuesday.'),
    // ── North ───────────────────────────────────────────────────────────────
    _SiteData('Jaffna Fort', 9.6615, 80.0074, 'History', 'FREE', 'A fort built by the Portuguese at Jaffna in 1618 and later taken by the Dutch. One of the best examples of Dutch colonial architecture in Asia.'),
    _SiteData('Nallur Kandaswamy Temple', 9.6749, 80.0264, 'History', 'FREE', 'One of the most significant Hindu temples in the Jaffna District, dedicated to Lord Murugan. The annual 25-day chariot festival (Jul/Aug) draws thousands of devotees.'),
    _SiteData('Nagadeepa Island Temple', 9.7778, 79.8347, 'History', 'FREE', 'A sacred Buddhist island temple near Jaffna, accessible only by ferry. One of the 16 sacred places (solosmasthana) where the Buddha is believed to have visited.'),
    _SiteData('Keerimalai Hot Springs', 9.7714, 80.0342, 'Nature', 'FREE', 'Natural springs on the Jaffna peninsula that well up from the sea bed. The waters are believed to have healing properties and people travel from across Sri Lanka to bathe.'),
    // ── East & Trincomalee ──────────────────────────────────────────────────
    _SiteData('Koneswaram Temple', 8.5857, 81.2342, 'History', 'FREE', 'An ancient Hindu temple dramatically perched on Swami Rock cliff overlooking Trincomalee harbour. One of the five sacred Iswarams (Pancha Ishwarams) of Shiva in Sri Lanka.'),
    _SiteData('Pigeon Island Marine Park', 8.7378, 81.2207, 'Nature', r'~$15 USD', 'One of two marine national parks in Sri Lanka, named for its resident rock pigeons. Exceptional snorkelling and diving amid coral reefs and blacktip reef sharks.'),
    _SiteData('Nilaveli Beach', 8.7205, 81.2075, 'Nature', 'FREE', 'An unspoiled, pristine beach near Trincomalee on the east coast. Crystal-clear waters, white sand and virtually no crowds — a paradise for those who seek it out.'),
    _SiteData('Kanniyai Hot Springs', 8.6125, 81.1999, 'Nature', 'FREE', 'Seven natural hot spring wells of different temperatures near Trincomalee, each with distinct temperatures. Legend links them to the tears of the demon king Ravana.'),
    _SiteData('Arugam Bay', 6.8427, 81.8266, 'Nature', 'FREE', 'Ranked one of the top 10 surf breaks in the world. The laid-back east coast village comes alive May–October with surfers from around the globe. Lagoon safaris too!'),
    _SiteData('Passikudah Bay', 7.9311, 81.5583, 'Nature', 'FREE', 'A sheltered bay with the calmest, clearest water in Sri Lanka — so shallow you can wade out 500m. Perfect for swimming year-round.'),
    _SiteData('Ampara', 7.2993, 81.6723, 'History', 'FREE', 'The gateway to the east, with nearby ancient Buddhist archaeological sites, crocodile-filled lagoons, and the stunning Deegawapi stupa.'),
    // ── Additional Major Sri Lanka Heritage Sites ───────────────────────────
    _SiteData('Buduruwagala Rock Carvings', 6.6835, 81.0549, 'History', '1000 LKR', 'Ancient 10th-century Buddhist complex featuring 7 massive rock-carved statues, including a 16-meter tall standing Buddha.'),
    _SiteData('Lankatilaka Vihara Kandy', 7.2694, 80.5638, 'History', '500 LKR', '14th-century architectural marvel built on a rock outcrop by King Bhuvanekabahu IV, blending Sinhala, Dravidian and Gampola styles.'),
    _SiteData('Gadaladeniya Temple', 7.2575, 80.5594, 'History', '300 LKR', 'Built in 1344 AD with South Indian influence, featuring a unique stone shrine and ancient frescoes from the Gampola Era.'),
    _SiteData('Embekke Devalaya', 7.2181, 80.5681, 'History', '300 LKR', 'Famous for its intricately carved wooden pillars in the Audience Hall, depicting mythical creatures, dancers, and wrestlers.'),
    _SiteData('Dambadeniya Ancient Kingdom', 7.3639, 80.1458, 'History', 'FREE', '13th-century capital city built on a fortified rock, home to ruins of the Royal Palace and Tooth Relic temple.'),
    _SiteData('Panduwasnuwara Kingdom', 7.6681, 80.1772, 'History', '500 LKR', 'An ancient 12th-century city featuring preserved moat walls, royal palace foundations, and legendary round tower ruins.'),
    _SiteData('Kurunegala Elephant Rock (Ethagala)', 7.4864, 80.3647, 'History', 'FREE', 'Dominating the city skyline, Ethagala features a giant 27-meter tall white Buddha statue with panoramic city views.'),
    _SiteData('Ritigala Strict Nature Reserve', 8.1186, 80.6583, 'Nature', '1000 LKR', 'Ancient 1st-century BC monastic cave complex hidden inside a misty mountain reserve with paved stone paths.'),
    _SiteData('Seruwila Mangala Raja Maha Vihara', 8.3756, 81.3175, 'History', 'FREE', 'Ancient 2nd-century BC stupa containing the sacred Lalata Dathu (frontal bone relic) of Lord Buddha.'),
    _SiteData('Kataragama Sacred City', 6.4133, 81.3325, 'History', 'FREE', 'One of Sri Lanka\'s most holy pilgrimage sites, venerated by Buddhists, Hindus, Muslims, and indigenous Vedda people.'),
    _SiteData('Tissamaharama Raja Maha Vihara', 6.2792, 81.2869, 'History', 'FREE', 'Massive ancient stupa built by King Kavantissa in the 3rd century BC in the historic kingdom of Ruhuna.'),
    _SiteData('Kirinda Raja Maha Vihara', 6.2139, 81.3364, 'History', 'FREE', 'Coastal cliff temple linked to Queen Viharamahadevi\'s legendary sea journey landing spot in ancient Sri Lanka.'),
    _SiteData('Mulkirigala Rock Temple', 6.1611, 80.7719, 'History', '500 LKR', 'Dramatic 205-meter high isolated rock temple featuring seven cave shrines and ancient murals spanning back 2000 years.'),
    _SiteData('Kevitiyagala Ancient Stupa', 6.7210, 80.0890, 'History', 'FREE', 'Secluded ancient monastic complex surrounded by lush rubber plantations in the Western Province.'),
    _SiteData('Kalutara Bodhiya', 6.5861, 79.9592, 'History', 'FREE', 'Famous hollow stupa built right next to the Kalu Ganga river, featuring a sacred Bodhi tree venerated for centuries.'),
    _SiteData('Richmond Castle Kalutara', 6.5744, 79.9764, 'Knowledge', '500 LKR', 'Edwardian mansion built in 1910 featuring 99 doors, Indian teak carvings, and stained glass imported from Scotland.'),
    _SiteData('Resvehera (Sasseruwa) Buddha', 8.0267, 80.3444, 'History', '500 LKR', 'Giant 12-meter tall unfinished standing Buddha statue carved out of a sheer rock wall in the 1st century BC.'),
    _SiteData('Nillakgama Bodhigara', 7.9250, 80.2520, 'History', 'FREE', 'The most complete and best-preserved ancient stone Bodhigara (shrine surrounding a Bodhi tree) structure in Sri Lanka.'),
    _SiteData('Aukana Buddha Statue', 8.0167, 80.5175, 'History', '1000 LKR', 'Magnificent 12-meter tall freestanding standing Buddha statue carved out of a single granite rock face in 5th century AD.'),
  ];

  @override
  void initState() {
    super.initState();
    _loadSites();
    _prepareOfflineTiles();
  }

  @override
  void dispose() {
    _search.dispose();
    _api.dispose();
    _mapController.dispose();
    _tileHttpClient.close();
    _progressSub?.cancel();
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

  Future<void> _prepareOfflineTiles() async {
    if (kIsWeb) return;
    try {
      final template = await SriLankaOfflineMapCache.instance.ensureLocalTemplate();
      if (mounted) setState(() => _offlineTileTemplate = template);

      // Fast path: tiles were fully downloaded in a previous session.
      final alreadyReady = await SriLankaOfflineMapCache.instance.isTilesReady();
      if (alreadyReady && mounted) {
        setState(() => _tilesReady = true);
        return;
      }

      // Show the banner immediately with a 0/total placeholder so the user
      // sees feedback before any tile actually finishes.
      final estimatedTotal = SriLankaOfflineMapCache.instance.countTotalTiles();
      if (mounted) {
        setState(() => _tileProgress = OfflineTileProgress(
            downloaded: 0, total: estimatedTotal));
      }

      // Subscribe BEFORE starting the download so we never miss the first event.
      _progressSub = SriLankaOfflineMapCache.instance.progressStream.listen(
        (progress) {
          if (!mounted) return;
          setState(() {
            _tileProgress = progress;
            if (progress.isComplete) _tilesReady = true;
          });
        },
        onError: (err) => debugPrint('Progress stream error: $err'),
      );

      // Kick off background download — errors are swallowed gracefully.
      unawaited(SriLankaOfflineMapCache.instance.warmSriLankaTiles().catchError((e) {
        debugPrint('Warm tiles error: $e');
      }));
    } catch (e) {
      debugPrint('Error preparing offline tiles: $e');
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

  // ── Ride There ────────────────────────────────────────────────────────────
  void _rideToSite(_SiteData site) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RidePickerSheet(site: site),
    );
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
          _buildDownloadBanner(),
          _bottomInfoCard(current),
          _buildZoomControls(current),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav(currentIndex: 1)),
        ]),
      ),
    );
  }

  /// Shows a persistent download banner while offline tiles are being fetched.
  Widget _buildDownloadBanner() {
    final progress = _tileProgress;
    // Hide when not yet started or fully complete.
    if (progress == null || progress.isComplete) return const SizedBox.shrink();

    final pct = (progress.fraction * 100).toStringAsFixed(0);
    final label = progress.isFailed
        ? '⚠️ Map download paused — will retry on next launch'
        : progress.downloaded == 0
            ? '📥 Preparing offline map tiles…'
            : '📥 Downloading offline map… $pct%';

    // Format tile counts cleanly: show as-is up to 9999, then Xk
    String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

    return Positioned(
      bottom: 115,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xF2100E0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                progress.isFailed
                    ? const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 14)
                    : const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              HeritageColors.orange),
                        ),
                      ),
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
                  '${_fmt(progress.downloaded)} / ${_fmt(progress.total)} tiles',
                  style: TextStyle(
                    color: HeritageColors.cream.withValues(alpha: 0.55),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.isFailed ? null : progress.fraction,
                minHeight: 4,
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
    );
  }


  Widget _buildZoomControls(_SiteData current) {
    return Positioned(
      right: 16,
      top: 130,
      child: Column(children: [
        _zoomButton(Icons.add, () {
          // Use a small step so the tile engine fetches ONE zoom level at a
          // time instead of jumping two — prevents blank white screens.
          final z = (_mapController.camera.zoom + 1.0).clamp(6.0, 18.0);
          _mapController.moveAndRotate(_mapController.camera.center, z, 0);
        }),
        const SizedBox(height: 8),
        _zoomButton(Icons.remove, () {
          final z = (_mapController.camera.zoom - 1.0).clamp(6.0, 18.0);
          _mapController.moveAndRotate(_mapController.camera.center, z, 0);
        }),
        const SizedBox(height: 8),
        _zoomButton(Icons.my_location, () {
          _mapController.move(LatLng(current.lat, current.lon), 11.5);
        }),
      ]),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xF01A1311),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: HeritageColors.orange, size: 20),
        ),
      ),
    );
  }

  Widget _mapBackground(List<_SiteData> filtered, _SiteData current) {
    // Only use file tiles once warmup is confirmed complete — avoids the slow
    // double-lookup (FileTileProvider miss → fallbackUrl network fetch).
    final localTileTemplate = _offlineTileTemplate;
    final useOfflineTiles = _tilesReady && localTileTemplate != null && !kIsWeb;
    final tileTemplate = useOfflineTiles ? localTileTemplate : _networkTileTemplate;
    return Positioned.fill(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(current.lat, current.lon),
          initialZoom: 8.5,
          minZoom: 6.0,
          maxZoom: 18.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
            enableMultiFingerGestureRace: true,
          ),
        ),
        children: [
          TileLayer(
            key: ValueKey<bool>(useOfflineTiles),
            urlTemplate: useOfflineTiles ? tileTemplate : _networkTileTemplate,
            // No {s} subdomain needed for OSM — subdomains list is empty
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
            panBuffer: 1,
            keepBuffer: 2,
            maxNativeZoom: 18,
            errorTileCallback: (tile, error, stackTrace) {
              debugPrint('Tile error at ${tile.coordinates}: $error');
            },
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
              Expanded(child: _actionButton('Scan Site', HeritageColors.orange, Icons.camera_alt, () => Navigator.of(context).pushNamed('/scanner'))),
              const SizedBox(width: 10),
              Expanded(child: _actionButton('Ride There', const Color(0xFF22C55E), Icons.local_taxi_rounded, () => _rideToSite(site))),
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

  Widget _actionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

// ── Ride Picker Bottom Sheet ──────────────────────────────────────────────────
class _RidePickerSheet extends StatelessWidget {
  final _SiteData site;
  const _RidePickerSheet({required this.site});

  Future<void> _launchPreferred(
    BuildContext ctx,
    List<Uri> preferred,
    Uri fallback,
  ) async {
    for (final uri in preferred) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          if (ctx.mounted) Navigator.pop(ctx);
          return;
        }
      } catch (_) {}
    }

    try {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    } catch (_) {}

    if (ctx.mounted) Navigator.pop(ctx);
  }

  void _openPickMe(BuildContext ctx) async {
    final lat = site.lat.toStringAsFixed(6);
    final lon = site.lon.toStringAsFixed(6);
    final name = Uri.encodeComponent(site.name);

    // PickMe passenger app — package: com.pickme.passenger
    // Try multiple URI schemes in order of specificity.
    final appUris = [
      // Standard custom scheme (works if PickMe registered this in their manifest)
      Uri.parse('pickme://open'),
      // Alternative scheme the passenger app may register
      Uri.parse('pickmepassenger://open'),
      // Android intent:// syntax understood by url_launcher on Android
      // This targets the package directly and falls through to the OS.
      Uri.parse(
        'intent://open'
        '#Intent;'
        'scheme=pickme;'
        'package=com.pickme.passenger;'
        'action=android.intent.action.VIEW;'
        'category=android.intent.category.BROWSABLE;'
        'end',
      ),
    ];

    // Fallbacks in order: PickMe website → Play Store listing
    final webFallback = Uri.parse(
        'https://pickme.lk/ride?destination_lat=$lat&destination_lng=$lon&destination_name=$name');
    final playStoreFallback = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.pickme.passenger');

    for (final uri in appUris) {
      try {
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (launched) {
            if (ctx.mounted) Navigator.pop(ctx);
            return;
          }
        }
      } catch (_) {}
    }

    // App not installed — try PickMe website first, then Play Store
    try {
      final launched = await launchUrl(webFallback, mode: LaunchMode.externalApplication);
      if (launched) {
        if (ctx.mounted) Navigator.pop(ctx);
        return;
      }
    } catch (_) {}

    try {
      await launchUrl(playStoreFallback, mode: LaunchMode.externalApplication);
    } catch (_) {}

    if (ctx.mounted) Navigator.pop(ctx);
  }


  void _openUber(BuildContext ctx) {
    final lat = site.lat.toStringAsFixed(6);
    final lon = site.lon.toStringAsFixed(6);
    final name = Uri.encodeComponent(site.name);
    // Uber web fallback — always opens Uber, not Google Maps
    final uberWeb = Uri.parse('https://m.uber.com/ul/?action=setPickup&pickup=my_location&dropoff%5Blatitude%5D=$lat&dropoff%5Blongitude%5D=$lon&dropoff%5Bnickname%5D=$name');
    _launchPreferred(
      ctx,
      [
        Uri.parse('uber://?action=setPickup&pickup=my_location&dropoff[latitude]=$lat&dropoff[longitude]=$lon&dropoff[nickname]=$name'),
      ],
      uberWeb,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1714),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Header
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_taxi_rounded, color: Color(0xFF22C55E), size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ride There', style: TextStyle(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    site.name,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // PickMe button
          _RideAppTile(
            emoji: '🛺',
            appName: 'PickMe',
            subtitle: 'Sri Lanka\'s #1 ride-hailing app',
            accentColor: const Color(0xFFFF6B00),
            onTap: () => _openPickMe(context),
          ),
          const SizedBox(height: 12),
          // Uber button
          _RideAppTile(
            emoji: '🚗',
            appName: 'Uber',
            subtitle: 'Available in Colombo & major cities',
            accentColor: const Color(0xFF1C1C1C),
            badgeColor: Colors.white,
            onTap: () => _openUber(context),
          ),
          const SizedBox(height: 20),
          // Destination info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: HeritageColors.orange, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Destination', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                      const SizedBox(height: 2),
                      Text(site.name, style: const TextStyle(color: HeritageColors.cream, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${site.lat.toStringAsFixed(4)}° N, ${site.lon.toStringAsFixed(4)}° E', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RideAppTile extends StatelessWidget {
  final String emoji;
  final String appName;
  final String subtitle;
  final Color accentColor;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _RideAppTile({
    required this.emoji,
    required this.appName,
    required this.subtitle,
    required this.accentColor,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // App icon
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accentColor.withValues(alpha: 0.4)),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            // App info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appName, style: TextStyle(color: badgeColor ?? accentColor, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
                ],
              ),
            ),
            // Arrow
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_rounded, color: badgeColor ?? accentColor, size: 18),
            ),
          ],
        ),
      ),
    );
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
