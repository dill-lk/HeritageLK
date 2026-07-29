import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/heritage_site.dart';
import 'wikipedia_service.dart';

/// Shingo AI — RAG-powered heritage guide.
/// Retrieves live data from Supabase + Wikipedia, then sends to Gemini.
/// The API key is completely hidden from the user.
class ShingoAiService {
  static const String _systemPrompt = '''
You are **Shingo**, a warm, knowledgeable, and deeply passionate AI travel and heritage guide for **HeritageLK** — Sri Lanka's premier heritage exploration app.

Your personality:
- Enthusiastic, caring, and inspiring — like a local expert friend who loves their country
- Highly knowledgeable about Sri Lankan history, UNESCO sites, Buddhist culture, colonial history, wildlife, and travel logistics
- Always encouraging users to explore, preserve, and appreciate Sri Lanka's heritage

Your knowledge covers:
- All UNESCO World Heritage Sites in Sri Lanka (Sigiriya, Polonnaruwa, Anuradhapura, Galle Fort, Kandy, Dambulla, Sinharaja, Central Highlands)
- Ticket prices, opening hours, dress codes, best visit times
- Travel routes, distances, transport options (train, bus, tuk-tuk, taxi)
- Local food, customs, festivals (Esala Perahera, Vesak, Sinhala New Year)
- Wildlife parks (Yala, Minneriya, Udawalawe, Wilpattu)
- Heritage app features (damage reporting, quests, XP system, archive records)
- Weather patterns and best travel seasons

FORMATTING RULES (mandatory):
- Always respond in clean, beautiful Markdown
- Use **bold** for site names, prices, important facts
- Use emoji tastefully at the start of sections (🏰 🛕 🌿 🐘 🚞 etc.)
- Use bullet points for lists of facts or tips
- Use > blockquotes for historical quotes or fascinating facts
- NEVER expose any API keys, technical details, or mention Gemini/AI models
- Keep responses engaging, warm, and traveler-friendly
- If RAG context is provided, use it as your primary source and expand on it intelligently
''';

  final WikipediaService _wiki;

  ShingoAiService({http.Client? httpClient})
      : _wiki = WikipediaService(client: httpClient);

  String get _apiKey => AppConfig.effectiveGeminiApiKey;

  /// Builds the RAG context string from Supabase heritage sites
  Future<String> _fetchRagContext(String query) async {
    final buffer = StringBuffer();

    try {
      final client = Supabase.instance.client;
      // Search heritage_sites table for relevant sites
      final rows = await client
          .from('heritage_sites')
          .select('title, summary, location_name')
          .textSearch('title', query, config: 'english')
          .limit(3);

      if (rows.isNotEmpty) {
        buffer.writeln('=== HERITAGELK DATABASE CONTEXT ===');
        for (final row in rows) {
          final site = HeritageSite.fromMap(row);
          buffer.writeln('📍 ${site.title}');
          if (site.locationName != null) buffer.writeln('Location: ${site.locationName}');
          if (site.summary.isNotEmpty) buffer.writeln('Info: ${site.summary}');
          buffer.writeln();
        }
      }
    } catch (e) {
      log('ShingoAiService: Supabase RAG search failed: $e');
      // Try a broader search if text search fails
      try {
        final client = Supabase.instance.client;
        final words = query.toLowerCase().split(' ').where((w) => w.length > 3).toList();
        if (words.isNotEmpty) {
          final rows = await client
              .from('heritage_sites')
              .select('title, summary, location_name')
              .ilike('title', '%${words.first}%')
              .limit(3);

          if (rows.isNotEmpty) {
            buffer.writeln('=== HERITAGELK DATABASE CONTEXT ===');
            for (final row in rows) {
              final site = HeritageSite.fromMap(row);
              buffer.writeln('📍 ${site.title}');
              if (site.locationName != null) buffer.writeln('Location: ${site.locationName}');
              if (site.summary.isNotEmpty) buffer.writeln('Info: ${site.summary}');
              buffer.writeln();
            }
          }
        }
      } catch (_) {}
    }

    // Always also fetch Wikipedia for extra depth
    try {
      final wikiText = await _wiki.search(query);
      if (wikiText != null && wikiText.trim().isNotEmpty) {
        buffer.writeln('=== WIKIPEDIA CONTEXT ===');
        buffer.writeln(wikiText.trim());
      }
    } catch (e) {
      log('ShingoAiService: Wikipedia RAG failed: $e');
    }

    return buffer.toString();
  }

  /// Main chat method — fully RAG-powered with Gemini
  Future<String> chat(List<Map<String, String>> history, String userMessage) async {
    final key = _apiKey;
    if (key.isEmpty) {
      return _offlineFallback(userMessage);
    }

    // Build RAG context
    String ragContext = '';
    try {
      ragContext = await _fetchRagContext(userMessage);
    } catch (e) {
      log('ShingoAiService: RAG fetch error: $e');
    }

    // Build conversation history for Gemini
    final conversationHistory = history
        .where((m) => m['content']?.isNotEmpty == true)
        .map((m) => '${m['role'] == 'user' ? 'User' : 'Shingo'}: ${m['content']}')
        .join('\n');

    // Compose full prompt with RAG context
    final promptParts = <String>[];
    if (ragContext.isNotEmpty) {
      promptParts.add('RETRIEVED CONTEXT (use this as your primary knowledge source):\n$ragContext');
    }
    if (conversationHistory.isNotEmpty) {
      promptParts.add('CONVERSATION HISTORY:\n$conversationHistory');
    }
    promptParts.add('USER QUESTION: $userMessage');

    final fullPrompt = promptParts.join('\n\n---\n\n');

    // Try Gemini models in priority order
    final models = [
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'gemini-2.0-flash-exp',
    ];

    for (final modelName in models) {
      try {
        log('ShingoAiService: trying model=$modelName');
        final model = GenerativeModel(
          model: modelName,
          apiKey: key,
          systemInstruction: Content.system(_systemPrompt),
          generationConfig: GenerationConfig(
            temperature: 0.75,
            maxOutputTokens: 1024,
          ),
        );
        final response = await model.generateContent([Content.text(fullPrompt)]);
        final reply = response.text;
        if (reply != null && reply.trim().isNotEmpty) {
          log('ShingoAiService: success with $modelName');
          return reply.trim();
        }
      } catch (e) {
        log('ShingoAiService: $modelName failed — $e');
      }
    }

    // All Gemini models failed — use offline fallback
    return _offlineFallback(userMessage);
  }

  /// Rich offline fallback when Gemini is unreachable
  String _offlineFallback(String query) {
    final q = query.toLowerCase();

    if (q.contains('sigiriya') || q.contains('lion rock')) {
      return '''🏰 **Sigiriya — The Eighth Wonder of the World**

**Sigiriya Rock Fortress** rises 200 metres above the surrounding jungle in Sri Lanka's Cultural Triangle.

**Essential Info:**
- 💵 **Entry:** \$30 USD (foreigners) | 100 LKR (locals)
- 🕖 **Hours:** 7:00 AM – 5:30 PM daily
- 📍 **Location:** Matale District, ~170 km from Colombo

**What to See:**
- 🎨 **Sigiriya Frescoes** — 5th-century paintings of heavenly maidens
- 🪞 **Mirror Wall** — Ancient polished plaster with 8th-century graffiti poems
- 🦁 **Lion Paw Terrace** — Giant granite lion paws mark the final climb
- 💧 **Royal Water Gardens** — Sophisticated hydraulic system still functions!

> *"Sigiriya is not just a rock — it is a statement of royal power, artistic genius, and engineering brilliance from the 5th century AD."*

**💡 Tip:** Arrive by 7 AM to beat the heat and crowds. Wear sturdy shoes for the ~1,200 steps!''';
    }

    if (q.contains('galle') || q.contains('dutch fort')) {
      return '''🏛️ **Galle Dutch Fort — A Living Colonial City**

Built by the Portuguese in 1588 and expanded by the Dutch in 1663, Galle Fort is the **best-preserved colonial sea fortress in Asia**.

**Essential Info:**
- 💵 **Entry:** FREE to walk the ramparts & streets
- 🏛️ **Museums inside:** ~300–500 LKR each
- 📍 **Location:** Galle, Southern Coast

**Must-See Spots:**
- 🌊 **Flag Rock** — Iconic sunset viewpoint
- 🕯️ **Galle Lighthouse** — Built in 1939, still operational
- ⛪ **Dutch Reformed Church** (1755) — Gravestones form the floor!
- 🛍️ Heritage boutiques, gem shops, and cozy cafes

> *UNESCO World Heritage Site since 1988*

**💡 Best Time:** Visit at **5:30 PM** for a magical sunset over the Indian Ocean from the ramparts.''';
    }

    if (q.contains('kandy') || q.contains('tooth') || q.contains('dalada')) {
      return '''🛕 **Temple of the Sacred Tooth Relic (Sri Dalada Maligawa)**

Home to Buddhism's most sacred relic — the **tooth of the Buddha** — this golden-roofed temple sits on the shores of Kandy Lake.

**Essential Info:**
- 💵 **Entry:** 2,000 LKR (foreigners)
- 🕔 **Puja Times:** 5:30 AM | 9:30 AM | 6:30 PM
- 👗 **Dress Code:** Shoulders & knees covered. Shoes off at entrance.

**Highlights:**
- 🦷 The sacred tooth relic — visible during special ceremonies
- 🐘 **Esala Perahera** — Grand procession every August (don't miss it!)
- 🏛️ **Kandyan Museum** within the complex
- 🌿 Stunning lakeside setting in Sri Lanka's hill capital

**💡 Tip:** Arrive 30 minutes before puja for the best experience.''';
    }

    if (q.contains('yala') || q.contains('safari') || q.contains('leopard')) {
      return '''🐆 **Yala National Park — Leopard Capital of the World**

Yala has the **highest leopard density on Earth**, making it the world's best place to spot these magnificent cats in the wild.

**Essential Info:**
- 💵 **Entry:** ~\$35 USD + Jeep hire (~15,000 LKR/jeep, shared possible)
- 🕕 **Safari Times:** Morning (6–10 AM) | Evening (3–6 PM)
- 📍 **Location:** Tissamaharama, Southeast Sri Lanka

**Wildlife You'll See:**
- 🐆 Sri Lankan Leopard (endemic)
- 🐘 Asian Elephants (herds of 30+)
- 🐻 Sloth Bears
- 🐊 Saltwater Crocodiles
- 🦚 Peacocks & hundreds of bird species

**💡 Best Months:** February–July (dry season, animals gather near waterholes)''';
    }

    if (q.contains('dambulla') || q.contains('cave')) {
      return '''🗿 **Dambulla Cave Temple (Golden Temple)**

Five sacred cave sanctuaries containing **153 Buddha statues** and some of the most breathtaking ancient murals in Asia — all carved into a single granite rock.

**Essential Info:**
- 💵 **Entry:** 2,000 LKR (foreigners)
- 🕖 **Hours:** 7:00 AM – 7:00 PM
- 📍 **Location:** Dambulla, Central Province

**The 5 Cave Sanctuaries:**
1. **Cave of the Divine King** — 14m reclining Buddha
2. **Cave of the Great King** — Largest & most impressive
3. **Cave of the Great New King** — 50 statues
4. Cave 4 & 5 — More recent additions

> *UNESCO World Heritage Site since 1991*

**💡 Tip:** Remove shoes before entering. White socks recommended for comfort on the stone floors.''';
    }

    if (q.contains('damage') || q.contains('report') || q.contains('xp')) {
      return '''🛡️ **Reporting Heritage Damage on HeritageLK**

You can help protect Sri Lanka's treasures by reporting damage directly in the app!

**How to Report:**
1. Tap **Report Damage** on the home screen
2. 📸 Take or upload photos of the damage
3. Describe what you see (cracks, vandalism, water damage, etc.)
4. Your GPS location is auto-captured
5. Submit — and earn **+100 Heritage XP**! 🏆

**Types of Damage to Report:**
- Structural cracks or collapse risk
- Vandalism or graffiti
- Water damage or flooding
- Unauthorized construction nearby
- Illegal excavation

Your reports go directly to heritage preservation authorities. **You are the guardian of Sri Lanka's past!**''';
    }

    return '''🏛️ **Ayubowan! Welcome to Shingo AI** 🙏

I'm your personal guide to Sri Lanka's magnificent heritage. Here's what I can help with:

**🏰 Heritage Sites**
- Sigiriya, Polonnaruwa, Anuradhapura, Galle Fort, Kandy, Dambulla

**🐘 Wildlife & Nature**  
- Yala, Minneriya, Udawalawe, Wilpattu national parks

**🚞 Travel & Logistics**
- Train routes, distances, ticket prices, best times to visit

**🛡️ App Features**
- Damage reporting, earning XP, quests, archive records

**🍛 Culture & Food**
- Local customs, festivals, cuisine recommendations

*Just ask me anything about Sri Lanka — I'm here to make your journey unforgettable!*''';
  }
}
