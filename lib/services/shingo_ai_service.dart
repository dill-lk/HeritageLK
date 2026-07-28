import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'wikipedia_service.dart';

class ShingoAiService {
  static const _systemPrompt = '''
You are Shingo, the exclusive AI assistant for HeritageLK, Sri Lanka's premier heritage and wildlife exploration app.
STRICT RULES:
- ONLY answer questions directly related to Sri Lankan heritage, wildlife, culture, history, entry fees, directions, weather, or the HeritageLK app itself.
- If a question is unrelated to HeritageLK or Sri Lankan heritage, politely refuse and say: "I only answer questions about Sri Lankan heritage and the HeritageLK app."
- NEVER answer general knowledge, coding, math, politics, entertainment, or any off-topic questions.
- When external context is provided, use it to enrich your answer. Cite sources naturally if context is present.
- Always answer in a friendly, concise way. Use emojis sparingly. Prioritize accuracy.
- If you don't know something, admit it honestly.
- Keep responses under 3 sentences unless the user asks for more detail.
''';

  GenerativeModel? _model;
  final WikipediaService _wiki;

  static const _offTopicIndicators = <String>[
    'joke', 'riddle', 'political', 'president', 'prime minister', 'salary', 'stock', 'bitcoin', 'crypto',
    'python', 'javascript', 'code', 'program', 'movie', 'actor', 'actress', 'music', 'song', 'game',
    'sports', 'football', 'cricket score', 'recipe', 'cook', 'doctor', 'medicine', 'lawyer', 'legal',
    'generate image', 'draw', 'poem', 'story', 'translate', 'language', 'date', 'love', 'relationship',
    'capital of france', 'capital of usa', 'what is ai', 'who are you', 'your name',
  ];

  ShingoAiService({String? apiKey, http.Client? httpClient})
      : _wiki = WikipediaService(client: httpClient) {
    if (apiKey != null && apiKey.isNotEmpty) {
      final models = <String>[
        'gemini-3.5-flash',
        'gemini-2.5-flash',
        'gemini-2.0-flash',
        'gemini-1.5-flash',
      ];
      for (final model in models) {
        try {
          _model = GenerativeModel(model: model, apiKey: apiKey, systemInstruction: Content.system(_systemPrompt));
          break;
        } catch (_) {
          continue;
        }
      }
    }
  }

  bool get isAvailable => _model != null;

  Future<String> chat(List<Map<String, String>> history, String userMessage) async {
    final lower = userMessage.toLowerCase();
    final isHeritageRelated = _isHeritageRelated(lower);

    if (!isHeritageRelated) {
      return 'I only answer questions about Sri Lankan heritage and the HeritageLK app. Ask me anything about heritage sites, entry fees, directions, weather, or the app itself!';
    }

    String? context;
    if (isHeritageRelated) {
      try {
        context = await _wiki.search(userMessage);
      } catch (_) {}
    }

    final prompt = context != null ? 'Context from Wikipedia:\n$context\n\nQuestion: $userMessage' : userMessage;

    try {
      final conversation = history.map((m) => '${m['role'] == 'user' ? 'User' : 'Shingo'}: ${m['content']}').join('\n');
      final fullPrompt = conversation.isNotEmpty ? '$conversation\n\nUser: $userMessage' : userMessage;
      if (_model == null) {
        return _fallbackReply(userMessage);
      }

      try {
        final chat = _model!.startChat();
        final response = await chat.sendMessage(Content.text(context != null ? 'Context from Wikipedia:\n$context\n\n$fullPrompt' : fullPrompt));
        final text = response.text;
        if (text == null || text.trim().isEmpty) {
          return _fallbackReply(userMessage);
        }
        return text.trim();
      } catch (_) {
        return _fallbackReply(userMessage);
      }
  }

  bool _isHeritageRelated(String lower) {
    final heritageKeywords = <String>[
      'heritage', 'site', 'temple', 'fort', 'rock', 'national park', 'wildlife', 'elephant', 'leopard',
      'sigiriya', 'galle', 'kandy', 'colombo', 'ella', 'anuradhapura', 'polonnaruwa', 'dambulla',
      'minneriya', 'yala', 'horton plains', 'adams peak', 'pinnawala', 'jaffna', 'mirissa',
      'nuwara eliya', 'anuradhapura', 'pollonnaruwa', 'rawana', 'arugam bay',
      'entry', 'ticket', 'price', 'fee', 'cost', 'free', 'usd', 'lkr',
      'weather', 'temperature', 'climate', 'rain', 'monsoon', 'season',
      'direction', 'how to reach', 'how to get', 'train', 'bus', 'flight', 'airport',
      'history', 'ancient', 'king', 'dutch', 'portuguese', 'british', 'unesco', 'world heritage',
      'buddhist', 'hindu', 'temple', 'shrine', 'mosque', 'church',
      'beach', 'surf', 'waterfall', 'mountain', 'hike', 'climb',
      'heritagelk', 'app', 'feature', 'quest', 'archive', 'scanner', 'map', 'profile', 'settings',
      'points', 'rank', 'level', 'badge', 'leaderboard',
      'shingo', 'ai', 'ask', 'help', 'assistant',
    ];

    final offTopic = _offTopicIndicators.any((indicator) => lower.contains(indicator));
    if (offTopic) return false;

    final related = heritageKeywords.any((keyword) => lower.contains(keyword));
    if (related) return true;

    if (lower.length < 3) return false;
    if (lower.contains('?')) {
      final questionWords = <String>['what', 'where', 'when', 'how', 'why', 'who', 'which', 'tell', 'explain', 'describe', 'show', 'list', 'find', 'search', 'recommend', 'suggest', 'plan', 'itinerary', 'visit', 'see', 'do', 'know'];
      if (questionWords.any((w) => lower.startsWith(w))) {
        return true;
      }
    }

    return false;
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
