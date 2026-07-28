import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'wikipedia_service.dart';

class ShingoAiService {
  static const _systemPrompt = '''
You are Shingo, the AI assistant for HeritageLK — Sri Lanka's heritage and wildlife exploration app.
You help with Sri Lankan heritage sites, wildlife, entry fees, directions, weather, history, and the app itself.
When external context is provided, use it to enrich your answer naturally. Cite sources if context is present.
Be friendly, concise, and helpful. Use emojis sparingly. If you don't know something, say so.
''';

  GenerativeModel? _model;
  final WikipediaService _wiki;

  ShingoAiService({String? apiKey, http.Client? httpClient})
      : _wiki = WikipediaService(client: httpClient) {
    if (apiKey == null || apiKey.isEmpty) {
      log('ShingoAiService: no API key provided');
      return;
    }

    final models = <String>[
      'gemini-1.5-flash',
      'gemini-1.5-flash-lite',
      'gemini-pro',
    ];

    for (final model in models) {
      try {
        _model = GenerativeModel(model: model, apiKey: apiKey, systemInstruction: Content.system(_systemPrompt));
        log('ShingoAiService: initialized model=$model');
        break;
      } catch (e) {
        log('ShingoAiService: model=$model failed: $e');
        continue;
      }
    }

    if (_model == null) {
      log('ShingoAiService: no valid model initialized for provided API key');
    }
  }

  bool get isAvailable => _model != null;

  Future<String> chat(List<Map<String, String>> history, String userMessage) async {
    if (_model == null) {
      return 'Shingo is offline right now. Please check GEMINI_API_KEY in CI secrets or run with --dart-define.';
    }

    String? context;
    try {
      context = await _wiki.search(userMessage);
    } catch (_e) {
      log('ShingoAiService: Wikipedia RAG failed: $_e');
    }

    try {
      final conversation = history.map((m) => '${m['role'] == 'user' ? 'User' : 'Shingo'}: ${m['content']}').join('\n');
      final fullPrompt = conversation.isNotEmpty ? '$conversation\n\nUser: $userMessage' : userMessage;
      final chat = _model!.startChat();
      final prompt = context != null ? 'Context from Wikipedia:\n$context\n\n$fullPrompt' : fullPrompt;
      log('ShingoAiService: sending prompt length=${prompt.length}');
      final response = await chat.sendMessage(Content.text(prompt));
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        return 'I couldn\'t generate a response. Try rephrasing?';
      }
      return text.trim();
    } catch (e) {
      log('ShingoAiService: chat failed: $e');
      return 'I\'m having trouble connecting right now. Please try again in a moment.';
    }
  }

  String _fallbackReply(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('galle fort')) return 'Galle Fort is a UNESCO World Heritage Site built by the Portuguese and later fortified by the Dutch. Entry is free and it offers amazing views, museums, and cobblestone streets. Best visited in the morning or late afternoon.';
    if (lower.contains('sigiriya')) return 'Sigiriya, also known as Lion Rock, is an ancient fortress built by King Kashyapa. Ticket prices are approximately \$30 for foreigners. Climb early in the morning to avoid the midday heat and crowds.';
    if (lower.contains('temple') || lower.contains('tooth')) return 'The Temple of the Sacred Tooth Relic in Kandy houses the relic of the Buddha\'s tooth. Dress modestly (covered shoulders and knees). Entry is free, but there may be a small fee for the museum.';
    if (lower.contains('weather') || lower.contains('temperature')) return 'Sri Lanka is tropical and generally hot and humid. Coastal areas like Galle average 28-32°C. The hill country is cooler at 18-24°C. Check the local forecast before heading out.';
    if (lower.contains('directions') || lower.contains('how to get')) return 'From Colombo to Galle, you can take the coastal train (about 2.5 hours) which is scenic, or drive via the Southern Expressway (about 1.5 hours).';
    return 'That\'s a great question about Sri Lankan heritage! Based on historical records, our island nation has over 2,500 years of documented history. Could you ask about a specific site, entry fee, or travel tip?';
  }
}
