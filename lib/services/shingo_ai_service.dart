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
      'gemini-2.5-flash',
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
    } catch (e) {
      log('ShingoAiService: Wikipedia RAG failed: $e');
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


}
