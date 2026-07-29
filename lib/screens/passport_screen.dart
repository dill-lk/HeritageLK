import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/passport_service.dart';
import '../theme/heritage_colors.dart';

class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key});

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
  List<PassportStamp> _stamps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPassport();
  }

  Future<void> _loadPassport() async {
    final stamps = await PassportService.getStamps();
    if (mounted) {
      setState(() {
        _stamps = stamps;
        _loading = false;
      });
    }
  }

  void _sharePassport() {
    final tier = PassportService.getTierName(_stamps.length);
    Share.share(
      '🏛️ I have earned ${_stamps.length} Heritage Stamps on my Digital Heritage Passport! Current Status: $tier Explorer. Join me in preserving Sri Lanka\'s legacy with HeritageLK! 🇱🇰',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = PassportService.getTierName(_stamps.length);

    return Scaffold(
      backgroundColor: HeritageColors.background,
      appBar: AppBar(
        backgroundColor: HeritageColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HeritageColors.cream),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Digital Heritage Passport',
          style: GoogleFonts.playfairDisplay(
            color: HeritageColors.cream,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: HeritageColors.orange),
            onPressed: _sharePassport,
            tooltip: 'Share Passport',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: HeritageColors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Passport Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C1E14), Color(0xFF1E140C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'HERITAGE PASSPORT',
                              style: GoogleFonts.plusJakartaSans(
                                color: HeritageColors.orange,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: HeritageColors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                tier,
                                style: const TextStyle(
                                  color: HeritageColors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sri Lanka Explorer',
                          style: GoogleFonts.playfairDisplay(
                            color: HeritageColors.cream,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_stamps.length} / 70 Heritage Sites Stamped',
                          style: TextStyle(
                            color: HeritageColors.cream.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (_stamps.length / 70).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(HeritageColors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Collected Stamps',
                        style: GoogleFonts.plusJakartaSans(
                          color: HeritageColors.cream,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Offline Verified 📍',
                        style: TextStyle(
                          color: HeritageColors.cream.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Grid of Stamps
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _stamps.length,
                    itemBuilder: (context, index) {
                      final stamp = _stamps[index];
                      return _buildStampCard(stamp);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStampCard(PassportStamp stamp) {
    final methodIcon = stamp.method == 'gps'
        ? Icons.location_on
        : stamp.method == 'scan'
            ? Icons.qr_code_scanner
            : Icons.military_tech;

    final dateStr = '${stamp.earnedAt.year}-${stamp.earnedAt.month.toString().padLeft(2, '0')}-${stamp.earnedAt.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1713),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: HeritageColors.orange.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Golden Seal Graphic
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF4A261), Color(0xFFE9C46A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: HeritageColors.orange.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(methodIcon, color: const Color(0xFF100E0A), size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            stamp.siteName,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: HeritageColors.cream,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            dateStr,
            style: TextStyle(
              color: HeritageColors.cream.withValues(alpha: 0.45),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
