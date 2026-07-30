import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/hotel_data.dart';
import '../theme/heritage_colors.dart';
import 'hotels_screen.dart';

class HotelDetailScreen extends StatelessWidget {
  final HotelData hotel;


  const HotelDetailScreen({super.key, required this.hotel});

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
    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Top Hero Image Header with Gallery / Real Photos
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: const Color(0xFF100E0A),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: HeritageColors.cream, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: hotel.galleryImages.isNotEmpty ? hotel.galleryImages[0] : hotel.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFF2A221C),
                            child: const Center(
                              child: CircularProgressIndicator(color: HeritageColors.orange),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF2A221C),
                            child: const Icon(Icons.hotel_rounded, color: HeritageColors.orange, size: 64),
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black38,
                                Colors.transparent,
                                Color(0xFF100E0A),
                              ],
                            ),
                          ),
                        ),
                        if (hotel.isPartner)
                          Positioned(
                            top: 56,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: HeritageColors.orange,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: HeritageColors.background, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'HERITAGE PARTNER',
                                    style: TextStyle(
                                      color: HeritageColors.background,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Main Hotel Details Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Rating Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotel.name,
                                    style: GoogleFonts.playfairDisplay(
                                      color: HeritageColors.cream,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, color: HeritageColors.orange, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Near ${hotel.nearSite} (${hotel.region})',
                                        style: const TextStyle(
                                          color: Color(0xFF52B788),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1714),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    hotel.price,
                                    style: const TextStyle(
                                      color: HeritageColors.orange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Color(0xFFE9C46A), size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${hotel.rating} (${hotel.stars}★)',
                                        style: const TextStyle(color: HeritageColors.cream, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 16),

                        // Authentic Photo Gallery
                        const Text(
                          'REAL RESORT PHOTOS',
                          style: TextStyle(
                            color: HeritageColors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hotel.galleryImages.length,
                            itemBuilder: (context, idx) {
                              final imgUrl = hotel.galleryImages[idx];
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white12),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CachedNetworkImage(
                                  imageUrl: imgUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: const Color(0xFF2A221C)),
                                  errorWidget: (_, __, ___) => const Icon(Icons.image, color: Colors.white38),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // About Section
                        const Text(
                          'ABOUT THIS HERITAGE STAY',
                          style: TextStyle(
                            color: HeritageColors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hotel.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Key Amenities
                        const Text(
                          'AMENITIES & HIGHLIGHTS',
                          style: TextStyle(
                            color: HeritageColors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: hotel.amenities.map((amenity) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1714),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Color(0xFF52B788), size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    amenity,
                                    style: const TextStyle(
                                      color: HeritageColors.cream,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Near Heritage Site Highlight
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1714),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF52B788).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF52B788).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.account_balance_rounded, color: Color(0xFF52B788), size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Heritage Neighbor',
                                      style: TextStyle(
                                        color: Color(0xFF52B788),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Minutes away from ${hotel.nearSite}',
                                      style: const TextStyle(
                                        color: HeritageColors.cream,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Sticky Action Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: const Color(0xF0100E0A),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(hotel.bookingUrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HeritageColors.orange,
                          foregroundColor: HeritageColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        label: const Text(
                          'Book Directly on Booking.com',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => _launchMaps(hotel.name, hotel.region),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HeritageColors.cream,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Icon(Icons.map_rounded, color: Color(0xFF52B788)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
