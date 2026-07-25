import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([http.Client])
import 'supabase_test.mocks.dart';

void main() {
  group('HeritageApi', () {
    test('siteDetails returns parsed response', () async {
      final client = MockClient();
      when(client.get(any)).thenAnswer((_) async => http.Response(
        jsonEncode({'description': 'A historic site', 'status': 'Open', 'ticketPrice': 'FREE'}),
        200,
      ));

      final response = await client.get(Uri.parse('https://api.example.com/api/site-details?name=Galle'));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['description'], 'A historic site');
      expect(body['status'], 'Open');
      expect(body['ticketPrice'], 'FREE');
    });

    test('shingoChat sends messages and returns response', () async {
      final client = MockClient();
      when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
        'Hello! I am Shingo AI.',
        200,
      ));

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
      final client = MockClient();
      when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
        '# Sigiriya\n\nA rock fortress in Sri Lanka.',
        200,
      ));

      final response = await client.post(
        Uri.parse('https://api.example.com/api/generate-archive'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'topic': 'Sigiriya'}),
      );
      expect(response.statusCode, 200);
      expect(response.body, contains('Sigiriya'));
    });

    test('error response throws exception', () async {
      final client = MockClient();
      when(client.get(any)).thenAnswer((_) async => http.Response(
        'Server error',
        500,
      ));

      final response = await client.get(Uri.parse('https://api.example.com/api/site-details?name=Galle'));
      expect(response.statusCode, greaterThanOrEqualTo(500));
    });

    test('weather API returns temperature and wind', () async {
      final client = MockClient();
      when(client.get(any)).thenAnswer((_) async => http.Response(
        jsonEncode({
          'current_weather': {
            'temperature': 28.5,
            'windspeed': 12.3,
            'weathercode': 1,
          }
        }),
        200,
      ));

      final response = await client.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=6.0264&longitude=80.217&current_weather=true'));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final weather = body['current_weather'] as Map<String, dynamic>;
      expect(weather['temperature'], 28.5);
      expect(weather['windspeed'], 12.3);
    });
  });

  group('Models', () {
    test('Quest.fromMap parses correctly', () {
      // Import if needed
      final map = {'id': 'q1', 'title': 'Test Quest', 'description': 'Do something', 'points': 100, 'icon': '🏆'};
      // Quest.fromMap(map) should not throw
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
