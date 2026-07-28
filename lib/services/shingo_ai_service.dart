import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'wikipedia_service.dart';

class ShingoAiService {
  static const _systemPrompt = '''
You are Shingo, the warm and knowledgeable AI travel guide for HeritageLK — Sri Lanka's heritage and wildlife exploration app.
You assist travelers, tourists, and culture lovers with Sri Lankan historical monuments, entry fees, travel routes, weather, culture, and app features.

IMPORTANT FORMATTING & DISPLAY GUIDELINES FOR USERS:
- Present all answers in clean, beautiful, human-friendly Markdown.
- Use bold text (**name**) for key highlights, prices, and locations.
- Use clean bulleted lists (• or -) for easy reading by travelers.
- Keep paragraphs clear, engaging, and well-spaced.
- DO NOT use developer code blocks, markdown code fences (```), monospaced technical snippets, or programming decorations. This chat is built for everyday travelers, NOT developers.
- Use relevant emojis tastefully to create an inviting travel guide feel.
''';

  final String? _apiKey;
  final WikipediaService _wiki;

  ShingoAiService({String? apiKey, http.Client? httpClient})
      : _apiKey = (apiKey != null && apiKey.isNotEmpty) ? apiKey : null,
        _wiki = WikipediaService(client: httpClient);

  String get effectiveKey {
    final key = _apiKey;
    if (key != null && key.isNotEmpty) return key;
    return AppConfig.effectiveGeminiApiKey;
  }

  bool get hasApiKey => effectiveKey.isNotEmpty;

  Future<String> chat(List<Map<String, String>> history, String userMessage) async {
    final key = effectiveKey;

    // 1. Try Gemini API if key is present
    if (key.isNotEmpty) {
      final candidateModels = ['gemini-1.5-flash', 'gemini-2.0-flash-exp', 'gemini-1.5-pro', 'gemini-2.0-flash', 'gemini-pro'];
      String? context;
      try {
        context = await _wiki.search(userMessage);
      } catch (e) {
        log('ShingoAiService: Wikipedia search failed: $e');
      }

      final conversation = history
          .map((m) => '${m['role'] == 'user' ? 'User' : 'Shingo'}: ${m['content']}')
          .join('\n');
      final fullPrompt = conversation.isNotEmpty ? '$conversation\n\nUser: $userMessage' : userMessage;
      final promptText = context != null && context.trim().isNotEmpty
          ? 'Wikipedia Context:\n$context\n\nQuery:\n$fullPrompt'
          : fullPrompt;

      for (final modelName in candidateModels) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: key,
            systemInstruction: Content.system(_systemPrompt),
          );
          log('ShingoAiService: attempting Gemini model=$modelName');
          final response = await model.generateContent([Content.text(promptText)]);
          final reply = response.text;
          if (reply != null && reply.trim().isNotEmpty) {
            return reply.trim();
          }
        } catch (e) {
          log('ShingoAiService: model $modelName failed: $e');
        }
      }
    }

    // 2. Offline / Fallback Intelligent Heritage Engine
    return await _generateFallbackResponse(userMessage);
  }

  Future<String> _generateFallbackResponse(String query) async {
    final q = query.toLowerCase();

    // Fetch Wikipedia context if possible
    String? wikiText;
    try {
      wikiText = await _wiki.search(query);
    } catch (_) {}

    if (q.contains('sigiriya')) {
      return '🏰 **Sigiriya Rock Fortress (Lion Rock)**\n\n'
          '• **Ticket Price:** \$30 USD (Foreign Adults) / ~50 LKR (Locals)\n'
          '• **Location:** Matale District, Central Province (~170km from Colombo)\n'
          '• **Highlights:** Ancient frescoes, Mirror Wall, Lion Paw Terrace, Royal Water Gardens.\n'
          '• **Best Time to Visit:** Early morning (7:00 AM) or late afternoon (3:30 PM) to avoid midday heat.\n\n'
          '${wikiText != null ? "*Historical Context:*\n$wikiText" : "Tip: Wear comfortable walking shoes and bring water for the ~1,200 step climb!"}';
    }

    if (q.contains('galle') || q.contains('fort')) {
      return '🏛️ **Galle Dutch Fort**\n\n'
          '• **Ticket Price:** FREE to enter fort ramparts & streets! (Museums charge ~300 LKR)\n'
          '• **Location:** Galle, Southern Coast of Sri Lanka\n'
          '• **Highlights:** Galle Lighthouse, Bastions, Colonial Dutch Architecture, Flag Rock sunset point.\n'
          '• **Best Time to Visit:** Sunset around 5:30 PM along the ramparts.\n\n'
          '${wikiText != null ? "*Historical Context:*\n$wikiText" : "Tip: Great cafes and heritage craft shops inside the fort walking area."}';
    }

    if (q.contains('tooth') || q.contains('kandy') || q.contains('dalada')) {
      return '🛕 **Temple of the Sacred Tooth Relic (Sri Dalada Maligawa)**\n\n'
          '• **Ticket Price:** 2,000 LKR (Foreign Adults)\n'
          '• **Location:** Kandy City Center\n'
          '• **Dress Code:** Shoulders and knees must be covered. Shoes removed at entrance.\n'
          '• **Pooja Times:** 5:30 AM, 9:30 AM, and 6:30 PM daily.\n\n'
          '${wikiText != null ? "*Details:*\n$wikiText" : ""}';
    }

    if (q.contains('yala') || q.contains('safari') || q.contains('leopard')) {
      return '🐆 **Yala National Park**\n\n'
          '• **Ticket Price:** ~\$35 USD + Jeep Hire (~15,000 LKR per jeep)\n'
          '• **Location:** Southeastern Sri Lanka (Tissamaharama)\n'
          '• **Highlights:** Highest leopard density in the world, wild elephants, sloth bears, crocodiles.\n'
          '• **Best Safari Time:** Morning safari (6:00 AM - 9:00 AM) or evening safari (3:00 PM - 6:00 PM).\n';
    }

    if (q.contains('dambulla')) {
      return '🗿 **Dambulla Cave Temple (Golden Temple)**\n\n'
          '• **Ticket Price:** 2,000 LKR (Foreigners)\n'
          '• **Highlights:** 5 cave sanctuaries with 153 Buddha statues and ancient ceiling murals.\n'
          '• **Location:** Dambulla, Central Province.\n';
    }

    if (q.contains('damage') || q.contains('report')) {
      return '🛡️ **Reporting Heritage Damage on HeritageLK**\n\n'
          'You can report structural cracks, vandalism, or water damage at any site!\n'
          '1. Tap **Report Damage** on the Home screen or menu.\n'
          '2. Take or upload photos of the issue.\n'
          '3. Enter details & location.\n'
          '4. Earn **+100 Heritage XP** once submitted!';
    }

    if (q.contains('api') || q.contains('key') || q.contains('gemini')) {
      return '⚡ **Gemini API Setup**\n\n'
          'To unlock full AI generative intelligence:\n'
          '1. Go to **Profile** or **Settings**.\n'
          '2. Paste your Google Gemini API Key under **Gemini AI Settings**.\n'
          '3. Tap Save Key! You can also pass `--dart-define=GEMINI_API_KEY=...` at build time.';
    }

    if (wikiText != null && wikiText.isNotEmpty) {
      return '🏛️ **Heritage Information**\n\n$wikiText\n\n*Powered by HeritageLK Knowledge Engine*';
    }

    return '🏛️ **Sri Lanka Heritage Guide**\n\n'
        'I am ready to help you explore Sri Lanka\'s top heritage sites! You can ask me about:\n'
        '• Ticket prices & entrance fees (Sigiriya, Galle Fort, Kandy, Dambulla, Yala)\n'
        '• Historical background & UNESCO World Heritage sites\n'
        '• Opening hours & dress code requirements\n'
        '• How to submit damage reports & earn XP\n'
        '• Setting up your Gemini API Key in app settings';
  }
}
