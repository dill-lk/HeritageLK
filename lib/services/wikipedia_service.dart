import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  final http.Client _client;

  WikipediaService({http.Client? client}) : _client = client ?? http.Client();

  /// Smart search: tries exact match first, then falls back to full-text search
  Future<String?> search(String query) async {
    // Extract key location/subject from query (first meaningful word)
    final keyword = _extractKeyword(query);
    if (keyword.isEmpty) return null;

    // 1. Try direct page summary with keyword
    final direct = await _fetchSummary(keyword);
    if (direct != null) return direct;

    // 2. Try Wikipedia OpenSearch to find the best matching article title
    try {
      final searchUri = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=opensearch&search=${Uri.encodeComponent(keyword)}&limit=1&format=json',
      );
      final res = await _client.get(searchUri).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        final titles = data[1] as List<dynamic>;
        if (titles.isNotEmpty) {
          final bestTitle = titles.first as String;
          return await _fetchSummary(bestTitle);
        }
      }
    } catch (_) {}

    return null;
  }

  Future<String?> _fetchSummary(String title) async {
    try {
      final uri = Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
      );
      final res = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final extract = data['extract'] as String?;
      final pageTitle = data['title'] as String?;
      if (extract == null || extract.isEmpty) return null;
      // Limit to first 400 chars to avoid bloating the prompt
      final trimmed = extract.length > 400 ? '${extract.substring(0, 400)}...' : extract;
      return pageTitle != null ? '$pageTitle: $trimmed' : trimmed;
    } catch (_) {
      return null;
    }
  }

  /// Pull the most relevant keyword from a free-form user query
  String _extractKeyword(String query) {
    final lower = query.toLowerCase();

    // Known Sri Lanka places/topics
    const keywords = {
      'sigiriya': 'Sigiriya',
      'lion rock': 'Sigiriya',
      'galle': 'Galle Fort',
      'dutch fort': 'Galle Fort',
      'kandy': 'Temple of the Tooth',
      'tooth relic': 'Temple of the Tooth',
      'dalada': 'Temple of the Tooth',
      'dambulla': 'Dambulla cave temple',
      'golden temple': 'Dambulla cave temple',
      'polonnaruwa': 'Polonnaruwa',
      'anuradhapura': 'Anuradhapura',
      'yala': 'Yala National Park',
      'leopard': 'Yala National Park',
      'safari': 'Yala National Park',
      'minneriya': 'Minneriya National Park',
      'elephant': 'Minneriya National Park',
      'sinharaja': 'Sinharaja Forest Reserve',
      'rainforest': 'Sinharaja Forest Reserve',
      'ella': 'Ella Sri Lanka',
      'train': 'Kandy to Ella railway',
      'adams peak': 'Adam\'s Peak',
      'sri pada': 'Adam\'s Peak',
      'nuwara eliya': 'Nuwara Eliya',
      'tea': 'Sri Lanka tea',
      'colombo': 'Colombo',
      'trincomalee': 'Trincomalee',
      'jaffna': 'Jaffna',
      'vesak': 'Vesak',
      'perahera': 'Esala Perahera',
      'udawalawe': 'Udawalawe National Park',
      'wilpattu': 'Wilpattu National Park',
    };

    for (final entry in keywords.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    // Fall back to first 2-3 meaningful words
    final words = query
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .take(2)
        .join(' ');
    return words.isNotEmpty ? words : query.split(' ').first;
  }

  void dispose() {
    _client.close();
  }
}
