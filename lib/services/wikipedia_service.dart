import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  static const _base = 'https://en.wikipedia.org/api/rest_v1/page/summary/';

  final http.Client _client;

  WikipediaService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> search(String query) async {
    try {
      final uri = Uri.parse('$_base${Uri.encodeComponent(query)}');
      final response = await _client.get(uri, headers: {'Accept': 'application/json'});
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final extract = data['extract'] as String?;
      final title = data['title'] as String?;
      if (extract == null || extract.isEmpty) return null;
      return title != null ? '$title: $extract' : extract;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
