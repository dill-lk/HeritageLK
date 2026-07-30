import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class PlantSpecies {
  final String name;
  final String sinhalaName;
  final String category;
  final String description;
  final String iconEmoji;
  final String heritageConnection;

  const PlantSpecies({
    required this.name,
    required this.sinhalaName,
    required this.category,
    required this.description,
    required this.iconEmoji,
    required this.heritageConnection,
  });
}

class DigitalGardenScreen extends StatefulWidget {
  const DigitalGardenScreen({super.key});

  @override
  State<DigitalGardenScreen> createState() => _DigitalGardenScreenState();
}

class _DigitalGardenScreenState extends State<DigitalGardenScreen> {
  String _selectedCategory = 'All';

  static const List<PlantSpecies> _flora = [
    PlantSpecies(
      name: 'Sacred Bo Tree (Jaya Sri Maha Bodhi)',
      sinhalaName: 'ජය ශ්‍රී මහා බෝධිය',
      category: 'Sacred Flora',
      description: 'Planted in 288 BC, the oldest human-planted tree in the world with a known planting date.',
      iconEmoji: '🌱',
      heritageConnection: 'Anuradhapura Sacred City',
    ),
    PlantSpecies(
      name: 'Ceylon Ironwood (Na Tree)',
      sinhalaName: 'නා ගස (Messua ferrea)',
      category: 'National Tree',
      description: 'National tree of Sri Lanka, valued for its fragrant white flowers and deep crimson young leaves.',
      iconEmoji: '🌳',
      heritageConnection: 'Na Uyana Aranya Sanctuary',
    ),
    PlantSpecies(
      name: 'Blue Water Lily (Nil Manel)',
      sinhalaName: 'නිල් මානෙල්',
      category: 'National Flower',
      description: 'National flower of Sri Lanka, symbol of purity and truth featured in ancient Sigiriya frescoes.',
      iconEmoji: '🪷',
      heritageConnection: 'Sigiriya Frescoes & Ancient Ponds',
    ),
    PlantSpecies(
      name: 'Kandyan Orchid (Vanda spathulata)',
      sinhalaName: 'වණ්ඩා ඕකීඩ්',
      category: 'Endemic Flora',
      description: 'Vibrant yellow orchid species native to the Central Highlands and Royal Botanic Gardens.',
      iconEmoji: '🌺',
      heritageConnection: 'Peradeniya Botanical Gardens',
    ),
    PlantSpecies(
      name: 'Kottamba (Country Almond)',
      sinhalaName: 'කොට්ටම්බා',
      category: 'Coastal Flora',
      description: 'Shade-providing tree lining the ancient ramparts and promenade of Galle Fort.',
      iconEmoji: '🍃',
      heritageConnection: 'Galle Fort Coastal Ramparts',
    ),
    PlantSpecies(
      name: 'Sandalwood (Handun)',
      sinhalaName: 'සුදු හඳුන්',
      category: 'Medicinal Flora',
      description: 'Aromatic wood historically used in Royal Kandyan court incense and traditional Ayurvedic medicine.',
      iconEmoji: '🪵',
      heritageConnection: 'Ritigala Medicinal Forest',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _flora
        : _flora.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                // Top Header
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
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
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HERITAGE ECOSYSTEM',
                          style: TextStyle(
                            color: HeritageColors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Digital Flora Garden',
                          style: GoogleFonts.playfairDisplay(
                            color: HeritageColors.cream,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Hero Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A2B), Color(0xFF122219)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF52B788).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('🌿', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Botanical & Sacred Flora',
                              style: TextStyle(
                                color: Color(0xFF52B788),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Explore Sri Lanka\'s living natural heritage intertwined with ancient kingdoms and UNESCO sites.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Sacred Flora', 'National Tree', 'National Flower', 'Endemic Flora', 'Medicinal Flora'].map((cat) {
                      final isSel = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat, style: TextStyle(
                            color: isSel ? HeritageColors.background : HeritageColors.cream,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                          selected: isSel,
                          selectedColor: const Color(0xFF52B788),
                          backgroundColor: const Color(0xFF1A1714),
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Flora Cards Grid
                ...filtered.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1714),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF52B788).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF52B788).withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(item.iconEmoji, style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.playfairDisplay(
                                color: HeritageColors.cream,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.sinhalaName,
                              style: const TextStyle(
                                color: Color(0xFF52B788),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.description,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.account_balance, color: HeritageColors.orange, size: 12),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.heritageConnection,
                                    style: const TextStyle(
                                      color: HeritageColors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
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
                )),
              ],
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
}
