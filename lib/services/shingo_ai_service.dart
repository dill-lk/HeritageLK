import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';
import 'wikipedia_service.dart';

class ShingoAiService {
  static const _systemPrompt = '''
You are Shingo, an advanced AI assistant for HeritageLK, Sri Lanka's premier heritage and wildlife exploration app.
You have deep knowledge about Sri Lankan heritage sites, wildlife, entry fees, weather, directions, history, and culture.
When external context is provided, use it to enrich your answer. Cite sources naturally if context is present.
Always answer in a friendly, concise way. Use emojis sparingly. Prioritize accuracy.
If you don't know something, admit it honestly.
Keep responses under 3 sentences unless the user asks for more detail.
''';

  GenerativeModel? _model;
  final WikipediaService _wiki;

  ShingoAiService({String? apiKey, http.Client? httpClient})
      : _wiki = WikipediaService(client: httpClient) {
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey, systemInstruction: Content.system(_systemPrompt));
      } catch (_) {
        try {
          _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey, systemInstruction: Content.system(_systemPrompt));
        } catch (_) {}
      }
    }
  }

  bool get isAvailable => _model != null;

  Future<String> chat(List<Map<String, String>> history, String userMessage) async {
    String? context;
    try {
      context = await _wiki.search(userMessage);
    } catch (_) {}

    final prompt = context != null ? 'Context from Wikipedia:\n$context\n\nQuestion: $userMessage' : userMessage;

    if (_model == null) {
      return _fallbackReply(userMessage);
    }

    try {
      final chat = _model!.startChat(history: _toGeminiHistory(history));
      final response = await chat.sendMessage(Content.text(prompt));
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        return _fallbackReply(userMessage);
      }
      return text.trim();
    } catch (_) {
      return _fallbackReply(userMessage);
    }
  }

  List<Content> _toGeminiHistory(List<Map<String, String>> history) {
    final result = <Content>[];
    for (final msg in history) {
      final text = msg['content'] ?? '';
      if (text.isEmpty) continue;
      result.add(msg['role'] == 'user' ? Content.user(text) : Content.model(text));
    }
    return result;
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
