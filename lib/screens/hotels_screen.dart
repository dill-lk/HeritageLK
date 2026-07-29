import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class _HotelData {
  final String name;
  final String nearSite;
  final double rating;
  final String price;
  final int stars;
  final String imageUrl;
  final String bookingUrl;
  final String region;
  final bool isFeatured;
  final bool isPartner;

  const _HotelData(
    this.name,
    this.nearSite,
    this.rating,
    this.price,
    this.stars,
    this.imageUrl,
    this.bookingUrl,
    this.region, {
    this.isFeatured = false,
    this.isPartner = false,
  });
}

const List<_HotelData> _kHotels = [
  _HotelData(
      'The Fort Printers',
      'Galle Dutch Fort',
      4.9,
      '\$120–\$280/night',
      5,
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=600',
      'https://www.booking.com/hotel/lk/the-fort-printers.html',
      'Galle',
      isFeatured: true,
      isPartner: true),
  _HotelData(
      'Amangalla',
      'Galle Dutch Fort',
      4.8,
      '\$400–\$900/night',
      5,
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?q=80&w=600',
      'https://www.booking.com/hotel/lk/amangalla.html',
      'Galle',
      isPartner: true),
  _HotelData(
      'Jetwing Lighthouse',
      'Galle Fort',
      4.7,
      '\$180–\$350/night',
      5,
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=600',
      'https://www.booking.com/hotel/lk/jetwing-lighthouse.html',
      'Galle'),
  _HotelData(
      'Cinnamon Lodge Habarana',
      'Sigiriya Rock',
      4.6,
      '\$90–\$220/night',
      4,
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=600',
      'https://www.booking.com/hotel/lk/cinnamon-lodge-habarana.html',
      'Sigiriya',
      isPartner: true),
  _HotelData(
      'Heritance Kandalama',
      'Sigiriya & Dambulla',
      4.8,
      '\$150–\$300/night',
      5,
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=600',
      'https://www.booking.com/hotel/lk/heritance-kandalama.html',
      'Sigiriya'),
  _HotelData(
      'The Kandy House',
      'Temple of Tooth Relic',
      4.7,
      '\$160–\$320/night',
      5,
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?q=80&w=600',
      'https://www.booking.com/hotel/lk/the-kandy-house.html',
      'Kandy',
      isPartner: true),
  _HotelData(
      'Amaya Hills Kandy',
      'Temple of Tooth Relic',
      4.5,
      '\$80–\$180/night',
      4,
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=600',
      'https://www.booking.com/hotel/lk/amaya-hills.html',
      'Kandy'),
  _HotelData(
      'Cinnamon Grand Colombo',
      'Galle Face Green',
      4.6,
      '\$130–\$260/night',
      5,
      'https://images.unsplash.com/photo-1455587734955-081b22074882?q=80&w=600',
      'https://www.booking.com/hotel/lk/cinnamon-grand-colombo.html',
      'Colombo',
      isPartner: true),
  _HotelData(
      'Galadari Hotel Colombo',
      'Colombo City',
      4.4,
      '\$80–\$160/night',
      4,
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=600',
      'https://www.booking.com/hotel/lk/galadari.html',
      'Colombo'),
  _HotelData(
      '98 Acres Resort Ella',
      'Nine Arches Bridge',
      4.8,
      '\$100–\$250/night',
      5,
      'https://images.unsplash.com/photo-1586116104802-d1e86c5d9f6e?q=80&w=600',
      'https://www.booking.com/hotel/lk/98-acres.html',
      'Ella',
      isFeatured: false,
      isPartner: true),
  _HotelData(
      'Ella Dream Cabana',
      'Ella Rock',
      4.5,
      '\$40–\$100/night',
      4,
      'https://images.unsplash.com/photo-1504215680853-026ed2a45def?q=80&w=600',
      'https://www.booking.com/searchresults.html?ss=Ella+Sri+Lanka',
      'Ella'),
];

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  String _selectedRegion = 'All';

  final List<String> _regions = [
    'All',
    'Galle',
    'Kandy',
    'Colombo',
    'Ella',
    'Sigiriya'
  ];

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  Future<void> _launchMaps(String query) async {
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

    final List<_HotelData> featuredHotels =
        filteredHotels.where((h) => h.isFeatured).toList();
    final List<_HotelData> regularHotels =
        filteredHotels.where((h) => !h.isFeatured).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF100E0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFEFAE0)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Text(
          'Hotels & Stays',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFFEFAE0),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildFilterChips(),
          ),
          if (featuredHotels.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildFeaturedCard(featuredHotels.first),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildRegularCard(regularHotels[index]);
                },
                childCount: regularHotels.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildFooter(context),
          ),
        ],
      ),
      bottomNavigationBar: const HeritageBottomNav(currentIndex: 3),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: _regions.map((region) {
          final isSelected = _selectedRegion == region;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRegion = region;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF4A261) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF4A261)
                        : const Color(0xFFFEFAE0).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  region,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF100E0A)
                        : const Color(0xFFFEFAE0),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedCard(_HotelData hotel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: GestureDetector(
        onTap: () => _launchUrl(hotel.bookingUrl),
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(hotel.imageUrl),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF100E0A).withOpacity(0.9),
                ],
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hotel.isPartner) _buildPartnerBadge(),
                const SizedBox(height: 8),
                Text(
                  hotel.name,
                  style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFFFEFAE0),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFFF4A261), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      hotel.nearSite,
                      style: TextStyle(
                        color: const Color(0xFFFEFAE0).withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    _buildStars(hotel.stars),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      hotel.price,
                      style: const TextStyle(
                        color: Color(0xFFFEFAE0),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          hotel.rating.toString(),
                          style: const TextStyle(
                            color: Color(0xFFFEFAE0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegularCard(_HotelData hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5E3C).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.network(
              hotel.imageUrl,
              width: 120,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 140,
                color: const Color(0xFF8B5E3C).withOpacity(0.3),
                child: const Icon(Icons.hotel, color: Color(0xFFFEFAE0)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: GoogleFonts.playfairDisplay(
                            color: const Color(0xFFFEFAE0),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hotel.isPartner) _buildPartnerBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFFF4A261), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.nearSite,
                          style: TextStyle(
                            color: const Color(0xFFFEFAE0).withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildStars(hotel.stars),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        hotel.price,
                        style: const TextStyle(
                          color: Color(0xFFFEFAE0),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            hotel.rating.toString(),
                            style: const TextStyle(
                              color: Color(0xFFFEFAE0),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionBtn(
                          'Book',
                          '🏨',
                          const Color(0xFFE9C46A),
                          () => _launchUrl(hotel.bookingUrl),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionBtn(
                          'Maps',
                          '📍',
                          const Color(0xFF52B788),
                          () => _launchMaps('${hotel.name} ${hotel.region} Sri Lanka'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF4A261).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF4A261)),
      ),
      child: const Text(
        'PARTNER',
        style: TextStyle(
          color: Color(0xFFF4A261),
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStars(int count) {
    return Text(
      '⭐' * count,
      style: const TextStyle(fontSize: 10),
    );
  }

  Widget _buildActionBtn(String text, String emoji, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _launchUrl(
                'https://www.booking.com/searchresults.html?ss=Sri+Lanka'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5E3C),
              foregroundColor: const Color(0xFFFEFAE0),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Browse All Hotels',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hotel links are affiliate partners. Booking fees support heritage preservation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFFEFAE0).withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
