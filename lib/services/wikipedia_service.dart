import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class WikipediaService {
  final http.Client _client;

  WikipediaService({http.Client? client}) : _client = client ?? http.Client();

  /// Smart search: tries keyword map first, then Wikipedia OpenSearch, then raw query
  Future<String?> search(String query) async {
    final keyword = _extractKeyword(query);
    if (keyword.isEmpty) return null;

    log('Wikipedia: searching for "$keyword" (from query: "$query")');

    // 1. Try direct page summary with mapped keyword
    final direct = await _fetchSummary(keyword);
    if (direct != null) {
      log('Wikipedia: direct hit for "$keyword"');
      return direct;
    }

    // 2. Try Wikipedia OpenSearch to find the best matching article
    try {
      final searchUri = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=opensearch&search=${Uri.encodeComponent(keyword)}&limit=3&format=json',
      );
      final res = await _client
          .get(searchUri, headers: {'User-Agent': 'HeritageLK/1.0'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        final titles = data[1] as List<dynamic>;
        for (final title in titles) {
          final summary = await _fetchSummary(title as String);
          if (summary != null) {
            log('Wikipedia: found via OpenSearch — "$title"');
            return summary;
          }
        }
      }
    } catch (e) {
      log('Wikipedia OpenSearch error: $e');
    }

    // 3. Last resort: try the raw first word of the query
    final firstWord = query.split(RegExp(r'\s+')).firstWhere(
      (w) => w.length > 3,
      orElse: () => query.split(' ').first,
    );
    if (firstWord != keyword) {
      return await _fetchSummary(firstWord);
    }

    return null;
  }

  Future<String?> _fetchSummary(String title) async {
    try {
      final uri = Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
      );
      final res = await _client
          .get(uri, headers: {'Accept': 'application/json', 'User-Agent': 'HeritageLK/1.0'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final extract = data['extract'] as String?;
      final pageTitle = data['title'] as String?;

      if (extract == null || extract.isEmpty) return null;

      // Limit to 500 chars for RAG — enough context without bloating the prompt
      final trimmed = extract.length > 500 ? '${extract.substring(0, 500)}...' : extract;
      return pageTitle != null ? '$pageTitle: $trimmed' : trimmed;
    } catch (e) {
      log('Wikipedia fetch error for "$title": $e');
      return null;
    }
  }

  /// Extract the most relevant search term from the user's query
  String _extractKeyword(String query) {
    final lower = query.toLowerCase();

    // Comprehensive Sri Lanka keyword map
    const keywords = {
      'sigiriya': 'Sigiriya',
      'lion rock': 'Sigiriya',
      'kashyapa': 'Sigiriya',
      'galle': 'Galle Fort',
      'dutch fort': 'Galle Fort',
      'fort galle': 'Galle Fort',
      'kandy': 'Temple of the Tooth Kandy',
      'tooth relic': 'Temple of the Tooth',
      'dalada': 'Temple of the Tooth',
      'esala perahera': 'Esala Perahera',
      'perahera': 'Esala Perahera',
      'dambulla': 'Dambulla cave temple',
      'golden temple': 'Dambulla cave temple',
      'cave temple': 'Dambulla cave temple',
      'polonnaruwa': 'Polonnaruwa',
      'gal vihara': 'Gal Vihara',
      'anuradhapura': 'Anuradhapura',
      'ruwanwelisaya': 'Ruwanwelisaya',
      'bodhi tree': 'Jaya Sri Maha Bodhi',
      'maha bodhi': 'Jaya Sri Maha Bodhi',
      'sinharaja': 'Sinharaja Forest Reserve',
      'rainforest': 'Sinharaja Forest Reserve',
      'yala': 'Yala National Park',
      'leopard': 'Sri Lankan leopard',
      'safari': 'Yala National Park',
      'minneriya': 'Minneriya National Park',
      'elephant': 'Sri Lankan elephant',
      'wilpattu': 'Wilpattu National Park',
      'udawalawe': 'Udawalawe National Park',
      'ella': 'Ella Sri Lanka',
      'nine arch': 'Nine Arch Bridge Ella',
      'train': 'Kandy to Ella railway',
      'railway': 'Sri Lanka railways',
      'adams peak': 'Adam\'s Peak',
      'sri pada': 'Adam\'s Peak',
      'adam peak': 'Adam\'s Peak',
      'nuwara eliya': 'Nuwara Eliya',
      'nuwara': 'Nuwara Eliya',
      'tea': 'Sri Lanka tea industry',
      'tea plantation': 'Sri Lanka tea industry',
      'colombo': 'Colombo',
      'trincomalee': 'Trincomalee',
      'trinco': 'Trincomalee',
      'jaffna': 'Jaffna',
      'vesak': 'Vesak',
      'sinhala': 'Sinhala people',
      'buddhism': 'Buddhism in Sri Lanka',
      'hindu': 'Hinduism in Sri Lanka',
      'dutch': 'Dutch colonialism Sri Lanka',
      'portuguese': 'Portuguese in Sri Lanka',
      'british': 'British Ceylon',
      'ceylon': 'Ceylon',
      'coral': 'Coral reef Sri Lanka',
      'whale': 'Blue whale Mirissa',
      'mirissa': 'Mirissa Sri Lanka',
      'unawatuna': 'Unawatuna beach',
      'hikkaduwa': 'Hikkaduwa',
      'arugam': 'Arugam Bay',
      'surfing': 'Arugam Bay',
      'diving': 'Hikkaduwa coral reef',
    };

    for (final entry in keywords.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    // Fall back to 2 meaningful words from the query
    final words = query
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .take(2)
        .join(' ');
    return words.isNotEmpty ? '$words Sri Lanka' : query.split(' ').first;
  }

  void dispose() {
    _client.close();
  }
}
