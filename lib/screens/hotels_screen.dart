import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:url_launcher/url_launcher.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

/// A dedicated cache manager for hotel images.
/// 7-day TTL + 60-image cap keeps the disk footprint small while making
/// repeated visits to this screen completely instant on Android.
class _HotelCacheManager {
  static const _key = 'heritage_hotels_v1';
  static final CacheManager _instance = CacheManager(Config(
    _key,
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 60,
  ));
  static CacheManager get cache => _instance;
}

class _HotelData {
  final String name;
  final String nearSite;
  final double rating;
  final String price;
  final int stars;
  final String imageUrl;
  final String bookingUrl;
  final String region;
  final bool isPartner;
  final String description;

  const _HotelData(
    this.name,
    this.nearSite,
    this.rating,
    this.price,
    this.stars,
    this.imageUrl,
    this.bookingUrl,
    this.region,
    this.description, {
    this.isPartner = false,
  });
}

const List<_HotelData> _kHotels = [
  _HotelData(
      'The Fort Printers',
      'Galle Dutch Fort',
      4.9,
      '\$140/night',
      5,
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=The+Fort+Printers+Galle',
      'Galle',
      '18th-century mansion turned boutique hotel located right inside the historic UNESCO ramparts of Galle Fort.',
      isPartner: true),
  _HotelData(
      'Amangalla',
      'Galle Dutch Fort',
      4.8,
      '\$450/night',
      5,
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Amangalla+Galle',
      'Galle',
      'Grand colonial heritage resort with 300 years of history overlooking Galle Fort lighthouse & ocean.',
      isPartner: true),
  _HotelData(
      'Jetwing Lighthouse',
      'Galle Fort Coast',
      4.7,
      '\$190/night',
      5,
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Jetwing+Lighthouse+Galle',
      'Galle',
      'Iconic cliffside tropical modernist masterpiece designed by legendary architect Geoffrey Bawa.',
      isPartner: false),
  _HotelData(
      'Heritance Kandalama',
      'Sigiriya & Dambulla',
      4.9,
      '\$160/night',
      5,
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Heritance+Kandalama+Sigiriya',
      'Sigiriya',
      'World-renowned eco-hotel built into the cliff face overlooking Sigiriya rock fortress and Kandalama lake.',
      isPartner: true),
  _HotelData(
      'Cinnamon Lodge Habarana',
      'Sigiriya Rock',
      4.6,
      '\$110/night',
      4,
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Cinnamon+Lodge+Habarana',
      'Sigiriya',
      'Sprawling 27-acre sanctuary surrounded by lush forest and lakes, minutes away from Sigiriya.',
      isPartner: false),
  _HotelData(
      'Aliya Resort & Spa',
      'Sigiriya Citadel',
      4.7,
      '\$130/night',
      4,
      'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Aliya+Resort+Sigiriya',
      'Sigiriya',
      'Theme resort featuring breathtaking infinity pool views facing the dramatic Sigiriya Lion Rock.',
      isPartner: true),
  _HotelData(
      'The Kandy House',
      'Temple of Tooth Relic',
      4.8,
      '\$180/night',
      5,
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=The+Kandy+House',
      'Kandy',
      'Exclusive 1804 ancestral manor turned luxury boutique hotel surrounded by tropical gardens near Kandy.',
      isPartner: true),
  _HotelData(
      'Amaya Hills Kandy',
      'Temple of Tooth Relic',
      4.5,
      '\$90/night',
      4,
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Amaya+Hills+Kandy',
      'Kandy',
      'Kandyan palace-inspired resort perched atop the Heerassagala hills with panoramic valley vistas.',
      isPartner: false),
  _HotelData(
      'Earl\'s Regency Hotel',
      'Kandy Sacred City',
      4.6,
      '\$120/night',
      5,
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Earls+Regency+Kandy',
      'Kandy',
      'Five-star luxury nestled along the Mahaweli River valley close to the Temple of the Sacred Tooth Relic.',
      isPartner: false),
  _HotelData(
      '98 Acres Resort & Spa',
      'Nine Arches Bridge',
      4.9,
      '\$210/night',
      5,
      'https://images.unsplash.com/photo-1586116104802-d1e86c5d9f6e?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=98+Acres+Resort+Ella',
      'Ella',
      'Scenic eco-luxury chalet resort built on a 98-acre tea estate overlooking Little Adam\'s Peak.',
      isPartner: true),
  _HotelData(
      'Ella Grand Peak',
      'Ella Gap & Rock',
      4.5,
      '\$65/night',
      4,
      'https://images.unsplash.com/photo-1504215680853-026ed2a45def?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Ella+Grand+Peak',
      'Ella',
      'Cozy mountain retreat with direct views of Ella Gap and easy access to Nine Arches Bridge.',
      isPartner: false),
  _HotelData(
      'Cinnamon Grand Colombo',
      'Galle Face Green',
      4.7,
      '\$150/night',
      5,
      'https://images.unsplash.com/photo-1455587734955-081b22074882?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Cinnamon+Grand+Colombo',
      'Colombo',
      'Premier 5-star city resort in the heart of Colombo near historic Dutch Hospital & Galle Face Green.',
      isPartner: true),
  _HotelData(
      'Galle Face Hotel',
      'Galle Face Promenade',
      4.8,
      '\$180/night',
      5,
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Galle+Face+Hotel+Colombo',
      'Colombo',
      'Founded in 1864, one of Asia\'s most iconic oceanfront heritage hotels located on Colombo\'s promenade.',
      isPartner: true),

  // ── Nuwara Eliya ──────────────────────────────────────────────────────────
  _HotelData(
      'Grand Hotel Nuwara Eliya',
      'Nuwara Eliya Tea Country',
      4.6,
      '\$95/night',
      5,
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Grand+Hotel+Nuwara+Eliya',
      'Nuwara Eliya',
      'A Victorian-era landmark hotel set in the cool highland mist, surrounded by manicured gardens and rolling tea estates.',
      isPartner: true),
  _HotelData(
      'Heritance Tea Factory',
      'Tea Plantation Estate',
      4.8,
      '\$175/night',
      5,
      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Heritance+Tea+Factory+Nuwara+Eliya',
      'Nuwara Eliya',
      'A converted working tea factory at 1,800m altitude. Rooms are fashioned from old machinery — a truly unique heritage experience in the clouds.',
      isPartner: true),
  _HotelData(
      'Jetwing St. Andrew\'s',
      'Nuwara Eliya Hill Station',
      4.5,
      '\$80/night',
      4,
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Jetwing+St+Andrews+Nuwara+Eliya',
      'Nuwara Eliya',
      'A charming colonial-style hotel offering cosy fireside comfort and sweeping views of Little England\'s misty hills and golf course.',
      isPartner: false),

  // ── Trincomalee ───────────────────────────────────────────────────────────
  _HotelData(
      'Jungle Beach by Uga Escapes',
      'Trincomalee Jungle Coast',
      4.9,
      '\$280/night',
      5,
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Jungle+Beach+Trincomalee',
      'Trincomalee',
      'Secluded eco-luxury camp on an untouched private beach near Trincomalee — sea turtle nesting, snorkelling and whale watching on your doorstep.',
      isPartner: true),
  _HotelData(
      'Trinco Blu by Cinnamon',
      'Nilaveli Beach',
      4.6,
      '\$140/night',
      5,
      'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Trinco+Blu+Cinnamon+Nilaveli',
      'Trincomalee',
      'A stunning beachfront resort on pristine Nilaveli Beach with direct access to Pigeon Island Marine Park for world-class snorkelling.',
      isPartner: false),

  // ── Anuradhapura ─────────────────────────────────────────────────────────
  _HotelData(
      'Ulagalla Resort',
      'Anuradhapura Sacred City',
      4.9,
      '\$320/night',
      5,
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Ulagalla+Resort+Anuradhapura',
      'Anuradhapura',
      'A magnificent eco-resort set on a 58-acre private estate with lakes, paddy fields and wild peacocks — the ultimate Anuradhapura ancient kingdom experience.',
      isPartner: true),
  _HotelData(
      'Palm Garden Village Hotel',
      'Ancient Anuradhapura Ruins',
      4.4,
      '\$70/night',
      4,
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Palm+Garden+Village+Anuradhapura',
      'Anuradhapura',
      'A tranquil garden resort offering comfortable chalets surrounded by coconut palms, just minutes from the sacred Anuradhapura archaeological sites.',
      isPartner: false),

  // ── Polonnaruwa ──────────────────────────────────────────────────────────
  _HotelData(
      'Deer Park Hotel Polonnaruwa',
      'Polonnaruwa Ancient Kingdom',
      4.5,
      '\$85/night',
      4,
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Deer+Park+Hotel+Polonnaruwa',
      'Polonnaruwa',
      'Set within a forest dotted with deer and peacocks, just minutes from the ancient medieval kingdom of Polonnaruwa — a UNESCO World Heritage Site.',
      isPartner: true),
  _HotelData(
      'The Lake Hotel Polonnaruwa',
      'Parakrama Samudra Lake',
      4.3,
      '\$55/night',
      3,
      'https://images.unsplash.com/photo-1504215680853-026ed2a45def?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Lake+Hotel+Polonnaruwa',
      'Polonnaruwa',
      'Overlooking the ancient Parakrama Samudra reservoir, this comfortable lakeside hotel is an ideal base for exploring the 12th-century ruined city.',
      isPartner: false),

  // ── Negombo ──────────────────────────────────────────────────────────────
  _HotelData(
      'Jetwing Blue',
      'Negombo Beach & Lagoon',
      4.7,
      '\$145/night',
      5,
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Jetwing+Blue+Negombo',
      'Negombo',
      'A sleek contemporary beachfront hotel steps from Negombo Beach — ideal as a first/last night stay after arrival at Bandaranaike International Airport.',
      isPartner: true),
  _HotelData(
      'Goldi Sands Hotel',
      'Negombo Beach',
      4.3,
      '\$60/night',
      4,
      'https://images.unsplash.com/photo-1455587734955-081b22074882?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Goldi+Sands+Negombo',
      'Negombo',
      'A popular beachfront property on Negombo\'s golden beach with a pool, seafood restaurant and easy access to the famous Dutch Canal and fish market.',
      isPartner: false),
  _HotelData(
      'Browns Beach Hotel',
      'Negombo Lagoon',
      4.4,
      '\$75/night',
      4,
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Browns+Beach+Hotel+Negombo',
      'Negombo',
      'A stylish beachfront resort with a large pool terrace, live music evenings and close proximity to the vibrant Negombo fish market and lagoon.',
      isPartner: false),

  // ── Bentota ──────────────────────────────────────────────────────────────
  _HotelData(
      'Taj Bentota Resort & Spa',
      'Bentota Beach & River',
      4.7,
      '\$200/night',
      5,
      'https://images.unsplash.com/photo-1586116104802-d1e86c5d9f6e?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Taj+Bentota+Resort+Spa',
      'Bentota',
      'A stunning luxury resort between the Bentota lagoon and Indian Ocean — Geoffrey Bawa-inspired design with exceptional water sports facilities.',
      isPartner: true),
  _HotelData(
      'Cinnamon Bey Beruwala',
      'Beruwala Lagoon',
      4.5,
      '\$110/night',
      5,
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=800',
      'https://www.booking.com/searchresults.html?ss=Cinnamon+Bey+Beruwala',
      'Bentota',
      'A beachfront resort on Sri Lanka\'s golden west coast, known for its Blue Flag beach, water sports centre and family-friendly atmosphere.',
      isPartner: false),
];

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  String _selectedRegion = 'All';

  final List<String> _regions = const [
    'All',
    'Galle',
    'Sigiriya',
    'Kandy',
    'Ella',
    'Colombo',
    'Nuwara Eliya',
    'Trincomalee',
    'Anuradhapura',
    'Polonnaruwa',
    'Negombo',
    'Bentota',
  ];

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  Future<void> _launchMaps(String name, String region) async {
    final query = '$name, $region, Sri Lanka';
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_HotelData> filteredHotels = _selectedRegion == 'All'
        ? _kHotels
        : _kHotels.where((h) => h.region == _selectedRegion).toList();

    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildTopHeader()),
                SliverToBoxAdapter(child: _buildRegionFilter()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildFullHotelCard(filteredHotels[index]);
                      },
                      childCount: filteredHotels.length,
                    ),
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: HeritageBottomNav(currentIndex: 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.arrow_back, color: HeritageColors.orange, size: 18),
            ),
          ),
          Column(
            children: [
              const Text(
                'HERITAGE STAYS',
                style: TextStyle(
                  color: HeritageColors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Hotels & Resorts',
                style: GoogleFonts.playfairDisplay(
                  color: HeritageColors.cream,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildRegionFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: _regions.map((region) {
          final isSelected = _selectedRegion == region;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRegion = region),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? HeritageColors.orange : const Color(0xFF1A1714),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? HeritageColors.orange
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  region,
                  style: TextStyle(
                    color: isSelected ? HeritageColors.background : HeritageColors.cream,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFullHotelCard(_HotelData hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1714),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width tall image banner
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: hotel.imageUrl.replaceAll('w=800', 'w=600'),
                cacheManager: _HotelCacheManager.cache,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                httpHeaders: const {
                  'User-Agent': 'HeritageLK/1.0 (Flutter; Android)',
                  'Accept': 'image/webp,image/png,image/*,*/*;q=0.8',
                },
                memCacheWidth: 600,
                memCacheHeight: 360,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => Container(
                  height: 220,
                  color: const Color(0xFF2A221C),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: HeritageColors.orange,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 220,
                  color: const Color(0xFF2A221C),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hotel_rounded, color: HeritageColors.orange, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Image unavailable',
                          style: TextStyle(color: HeritageColors.cream, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Gradient shadow overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Partner Badge
              if (hotel.isPartner)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: HeritageColors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: HeritageColors.background, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'HERITAGE PARTNER',
                          style: TextStyle(
                            color: HeritageColors.background,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Price Tag
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF100E0A).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    hotel.price,
                    style: const TextStyle(
                      color: HeritageColors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Rating Badge
              Positioned(
                bottom: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFE9C46A), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel.rating} (${hotel.stars}★)',
                        style: const TextStyle(
                          color: HeritageColors.cream,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Details content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: GoogleFonts.playfairDisplay(
                    color: HeritageColors.cream,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: HeritageColors.orange, size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hotel.nearSite,
                        style: const TextStyle(
                          color: Color(0xFF52B788),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  hotel.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(hotel.bookingUrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HeritageColors.orange,
                          foregroundColor: HeritageColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.hotel_rounded, size: 18),
                        label: const Text(
                          'Book Hotel',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _launchMaps(hotel.name, hotel.region),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HeritageColors.cream,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.map_rounded, size: 18, color: Color(0xFF52B788)),
                      label: const Text('Map', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
