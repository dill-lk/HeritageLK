import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/heritage_feed_service.dart';
import '../theme/heritage_colors.dart';

class HeritageFeedScreen extends StatefulWidget {
  const HeritageFeedScreen({super.key});

  @override
  State<HeritageFeedScreen> createState() => _HeritageFeedScreenState();
}

class _HeritageFeedScreenState extends State<HeritageFeedScreen> {
  List<HeritageFeedItem> _feedItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final items = await HeritageFeedService.getFeedItems();
    if (mounted) {
      setState(() {
        _feedItems = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.background,
      appBar: AppBar(
        backgroundColor: HeritageColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: HeritageColors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hub_outlined, color: HeritageColors.orange, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Heritage Feed',
              style: GoogleFonts.playfairDisplay(
                color: HeritageColors.cream,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: HeritageColors.orange))
          : RefreshIndicator(
              onRefresh: _loadFeed,
              color: HeritageColors.orange,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _feedItems.length,
                itemBuilder: (context, index) {
                  final item = _feedItems[index];
                  return _buildFeedCard(item);
                },
              ),
            ),
    );
  }

  Widget _buildFeedCard(HeritageFeedItem item) {
    final typeBadge = item.type == 'journal'
        ? ('📸 Journal', Colors.amber)
        : item.type == 'damage'
            ? ('🛡️ Damage Guard', Colors.orange)
            : item.type == 'quest'
                ? ('🏆 Quest Completed', Colors.green)
                : ('📚 Archive Contribution', Colors.blue);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF181511),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User & Badge Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: HeritageColors.orange.withValues(alpha: 0.2),
                child: Text(item.userAvatar, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.userName,
                      style: GoogleFonts.plusJakartaSans(
                        color: HeritageColors.cream,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.siteName,
                      style: TextStyle(
                        color: HeritageColors.orange.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeBadge.$2.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: typeBadge.$2.withValues(alpha: 0.4)),
                ),
                child: Text(
                  typeBadge.$1,
                  style: TextStyle(
                    color: typeBadge.$2,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Content
          Text(
            item.content,
            style: TextStyle(
              color: HeritageColors.cream.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.5,
            ),
          ),

          if (item.imageUrl != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.white10,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white38),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_border_rounded, color: HeritageColors.orange, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${item.likes}',
                    style: const TextStyle(color: HeritageColors.cream, fontSize: 12),
                  ),
                ],
              ),
              Text(
                '${item.createdAt.hour}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: HeritageColors.cream.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
