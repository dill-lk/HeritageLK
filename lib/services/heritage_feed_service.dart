import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class HeritageFeedItem {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String type; // 'journal', 'damage', 'archive', 'quest'
  final String siteId;
  final String siteName;
  final String content;
  final String? imageUrl;
  final int likes;
  final DateTime createdAt;

  HeritageFeedItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.type,
    required this.siteId,
    required this.siteName,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.createdAt,
  });
}

class HeritageFeedService {
  static Future<List<HeritageFeedItem>> getFeedItems() async {
    if (AppConfig.hasSupabase) {
      try {
        final res = await Supabase.instance.client
            .from('heritage_feed')
            .select()
            .order('created_at', ascending: false)
            .limit(20);

        return (res as List).map((row) {
          return HeritageFeedItem(
            id: row['id'] as String,
            userId: row['user_id'] as String? ?? 'anon',
            userName: row['user_name'] as String? ?? 'Heritage Explorer',
            userAvatar: row['user_avatar'] as String? ?? '👤',
            type: row['type'] as String? ?? 'journal',
            siteId: row['site_id'] as String? ?? 'sigiriya',
            siteName: row['site_name'] as String? ?? 'Sigiriya Fortress',
            content: row['content'] as String? ?? '',
            imageUrl: row['image_url'] as String?,
            likes: (row['likes'] as int?) ?? 0,
            createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
          );
        }).toList();
      } catch (_) {
        // Fallback to pre-seeded items if table doesn't exist yet
        return _getPreseededFeed();
      }
    }
    return _getPreseededFeed();
  }

  static List<HeritageFeedItem> _getPreseededFeed() {
    return [
      HeritageFeedItem(
        id: '1',
        userId: 'u1',
        userName: 'Sanul Randisa',
        userAvatar: '👑',
        type: 'journal',
        siteId: 'sigiriya',
        siteName: 'Sigiriya Rock Fortress',
        content: 'Climbed the Lion Rock at sunrise today! The Cloud Maidens frescoes are breathtaking. Preserving Sri Lankan history for generations to come. 🌄🏛️',
        imageUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
        likes: 24,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      HeritageFeedItem(
        id: '2',
        userId: 'u2',
        userName: 'Kavindi Perera',
        userAvatar: '🛡️',
        type: 'damage',
        siteId: 'galle_fort',
        siteName: 'Galle Dutch Fort',
        content: 'Reported minor weathering cracks on the Triton Bastion seawall. Heritage Department has received the status: In Review.',
        imageUrl: null,
        likes: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      HeritageFeedItem(
        id: '3',
        userId: 'u3',
        userName: 'Nimal Silva',
        userAvatar: '🏆',
        type: 'quest',
        siteId: 'temple_tooth',
        siteName: 'Temple of the Tooth',
        content: 'Just completed the "Kingdom Guardian Quest" and earned the Gold Explorer Stamp! 🏰📜',
        imageUrl: null,
        likes: 38,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }
}
