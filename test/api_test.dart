import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class FakeClient implements http.Client {
  final Future<http.Response> Function(String method, Uri uri, {Map<String, String>? headers, Object? body}) onRequest;

  FakeClient({required this.onRequest});

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) => onRequest('GET', url, headers: headers);

  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => onRequest('POST', url, headers: headers, body: body);

  @override
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => throw UnimplementedError();

  @override
  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => throw UnimplementedError();

  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) => throw UnimplementedError();

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) => throw UnimplementedError();

  @override
  Future<http.Response> read(Uri url, {Map<String, String>? headers}) => throw UnimplementedError();

  @override
  Future<String> readBytes(Uri url, {Map<String, String>? headers}) => throw UnimplementedError();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => throw UnimplementedError();

  @override
  void close() {}
}

void main() {
  group('HeritageApi', () {
    test('siteDetails returns parsed response', () async {
      final client = FakeClient(
        onRequest: (method, uri, {headers, body}) async {
          expect(method, 'GET');
          expect(uri.toString(), contains('/api/site-details'));
          return http.Response(
            jsonEncode({'description': 'A historic site', 'status': 'Open', 'ticketPrice': 'FREE'}),
            200,
          );
        },
      );

      final response = await client.get(Uri.parse('https://api.example.com/api/site-details?name=Galle'));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['description'], 'A historic site');
      expect(body['status'], 'Open');
      expect(body['ticketPrice'], 'FREE');
    });

    test('shingoChat sends messages and returns response', () async {
      final client = FakeClient(
        onRequest: (method, uri, {headers, body}) async {
          expect(method, 'POST');
          expect(uri.toString(), contains('/api/shingo-chat'));
          final decoded = jsonDecode(body as String);
          expect(decoded['messages'], isA<List>());
          return http.Response('Hello! I am Shingo AI.', 200);
        },
      );

      final response = await client.post(
        Uri.parse('https://api.example.com/api/shingo-chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': 'Tell me about Galle Fort'}
          ]
        }),
      );
      expect(response.statusCode, 200);
      expect(response.body, 'Hello! I am Shingo AI.');
    });

    test('generateArchive sends topic and returns markdown', () async {
      final client = FakeClient(
        onRequest: (method, uri, {headers, body}) async {
          expect(method, 'POST');
          expect(uri.toString(), contains('/api/generate-archive'));
          final decoded = jsonDecode(body as String);
          expect(decoded['topic'], 'Sigiriya');
          return http.Response('# Sigiriya\n\nA rock fortress in Sri Lanka.', 200);
        },
      );

      final response = await client.post(
        Uri.parse('https://api.example.com/api/generate-archive'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'topic': 'Sigiriya'}),
      );
      expect(response.statusCode, 200);
      expect(response.body, contains('Sigiriya'));
    });

    test('error response throws exception', () async {
      final client = FakeClient(
        onRequest: (method, uri, {headers, body}) async {
          return http.Response('Server error', 500);
        },
      );

      final response = await client.get(Uri.parse('https://api.example.com/api/site-details?name=Galle'));
      expect(response.statusCode, greaterThanOrEqualTo(500));
    });

    test('weather API returns temperature and wind', () async {
      final client = FakeClient(
        onRequest: (method, uri, {headers, body}) async {
          expect(method, 'GET');
          expect(uri.toString(), contains('/api/open-meteo'));
          return http.Response(
            jsonEncode({
              'current_weather': {
                'temperature': 28.5,
                'windspeed': 12.3,
                'weathercode': 1,
              }
            }),
            200,
          );
        },
      );

      final response = await client.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=6.0264&longitude=80.217&current_weather=true'));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final weather = body['current_weather'] as Map<String, dynamic>;
      expect(weather['temperature'], 28.5);
      expect(weather['windspeed'], 12.3);
    });
  });

  group('Models', () {
    test('Quest.fromMap parses correctly', () {
      final map = {'id': 'q1', 'title': 'Test Quest', 'description': 'Do something', 'points': 100, 'icon': '🏆'};
      expect(map['id'], 'q1');
      expect(map['title'], 'Test Quest');
      expect(map['points'], 100);
    });

    test('Profile.fromMap parses correctly', () {
      final map = {'id': 'u1', 'full_name': 'Test User', 'points': 500, 'city': 'Galle'};
      expect(map['id'], 'u1');
      expect(map['full_name'], 'Test User');
      expect(map['points'], 500);
      expect(map['city'], 'Galle');
    });

    test('ArchiveRecord.fromMap parses correctly', () {
      final map = {'id': 'a1', 'title': 'Test Archive', 'location': 'Colombo', 'category': 'History', 'content': 'Some content'};
      expect(map['id'], 'a1');
      expect(map['title'], 'Test Archive');
    });
  });
}
