import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PassportStamp {
  final String siteId;
  final String siteName;
  final DateTime earnedAt;
  final String method; // 'gps' | 'scan' | 'quest'
  final String? category;

  PassportStamp({
    required this.siteId,
    required this.siteName,
    required this.earnedAt,
    required this.method,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'siteId': siteId,
        'siteName': siteName,
        'earnedAt': earnedAt.toIso8601String(),
        'method': method,
        'category': category,
      };

  factory PassportStamp.fromJson(Map<String, dynamic> json) {
    return PassportStamp(
      siteId: json['siteId'] as String,
      siteName: json['siteName'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      method: json['method'] as String? ?? 'gps',
      category: json['category'] as String?,
    );
  }
}

class PassportService {
  static const String _key = 'heritage_passport_stamps_v1';

  static Future<List<PassportStamp>> getStamps() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      // Seed with initial stamps for demo
      final initial = _getPreseededStamps();
      await saveStamps(initial);
      return initial;
    }
    try {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => PassportStamp.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getPreseededStamps();
    }
  }

  static Future<void> saveStamps(List<PassportStamp> stamps) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(stamps.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<bool> addStamp(PassportStamp newStamp) async {
    final current = await getStamps();
    if (current.any((s) => s.siteId.toLowerCase() == newStamp.siteId.toLowerCase())) {
      return false; // Already earned
    }
    current.add(newStamp);
    await saveStamps(current);
    return true;
  }

  static List<PassportStamp> _getPreseededStamps() {
    return [
      PassportStamp(
        siteId: 'sigiriya',
        siteName: 'Sigiriya Rock Fortress',
        earnedAt: DateTime.now().subtract(const Duration(days: 4)),
        method: 'gps',
        category: 'UNESCO Heritage',
      ),
      PassportStamp(
        siteId: 'galle_fort',
        siteName: 'Galle Dutch Fort',
        earnedAt: DateTime.now().subtract(const Duration(days: 2)),
        method: 'scan',
        category: 'Fortress',
      ),
      PassportStamp(
        siteId: 'temple_tooth',
        siteName: 'Temple of the Tooth',
        earnedAt: DateTime.now().subtract(const Duration(days: 1)),
        method: 'quest',
        category: 'Sacred Site',
      ),
      PassportStamp(
        siteId: 'nine_arch',
        siteName: 'Nine Arch Bridge',
        earnedAt: DateTime.now().subtract(const Duration(hours: 12)),
        method: 'gps',
        category: 'Colonial Rail',
      ),
      PassportStamp(
        siteId: 'anuradhapura',
        siteName: 'Sacred City of Anuradhapura',
        earnedAt: DateTime.now().subtract(const Duration(hours: 4)),
        method: 'scan',
        category: 'Ancient Capital',
      ),
      PassportStamp(
        siteId: 'dambulla',
        siteName: 'Dambulla Cave Temple',
        earnedAt: DateTime.now(),
        method: 'gps',
        category: 'Cave Temple',
      ),
    ];
  }

  static String getTierName(int stampCount) {
    if (stampCount >= 35) return 'Heritage Legend';
    if (stampCount >= 15) return 'Gold Explorer';
    if (stampCount >= 5) return 'Silver Pathfinder';
    return 'Bronze Visitor';
  }
}
