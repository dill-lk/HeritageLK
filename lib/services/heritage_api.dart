import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class HeritageApi {
  HeritageApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> siteDetails(String siteName) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/site-details').replace(
      queryParameters: {'name': siteName},
    );
    final response = await _client.get(uri);
    return _decode(response);
  }

  Future<String> shingoChat(List<Map<String, String>> messages) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/shingo-chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'messages': messages}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to connect to Shingo AI.');
    }
    return response.body;
  }

  Future<String> generateArchive(String topic) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/generate-archive'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'topic': topic}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to generate archive.');
    }
    return response.body;
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HeritageLK server returned ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid HeritageLK server response.');
    }
    return decoded;
  }
}
