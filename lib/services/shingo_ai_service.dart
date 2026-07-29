import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import 'wikipedia_service.dart';

/// Shingo — RAG-powered, personality-driven AI heritage guide.
/// Gemini API is fully embedded. Users never see or configure it.
class ShingoAiService {
  // Shingo's personality — short, punchy, human. Gemini listens to short prompts better.
  static const String _systemPrompt = '''
You are Shingo — a fun, passionate, local Sri Lankan heritage guide inside the HeritageLK app.

PERSONALITY:
- Talk like a knowledgeable local friend, NOT a boring textbook or robot
- Be warm, enthusiastic, occasionally throw in a Sri Lankan phrase or expression
- Use storytelling — paint a picture of what the user will experience
- Show genuine excitement about Sri Lanka's history and nature
- Ask follow-up questions to keep the conversation going naturally
- Use light humour when appropriate

KNOWLEDGE:
- Deep expert on all Sri Lanka UNESCO World Heritage Sites
- Know ticket prices, opening hours, travel tips, local food, wildlife
- Know the HeritageLK app features (quests, damage reports, XP, archive)
- Keep facts accurate — if you're not sure, say so honestly

FORMAT:
- Use markdown: **bold** for names/prices, • bullets for lists, emojis at section starts
- Keep responses conversational length — not too short, not an essay
- For complex topics use clear sections with emoji headers
- NEVER mention Gemini, AI models, API keys, or any technical backend
- NEVER be robotic or give dry FAQ-style answers
''';

  final WikipediaService _wiki = WikipediaService();

  String get _key => AppConfig.effectiveGeminiApiKey;

  // ─── Main chat entry point ─────────────────────────────────────────
  Future<String> chat(
    List<Map<String, String>> history,
    String userMessage,
  ) async {
    if (_key.isEmpty) return _richFallback(userMessage);

    // 1. Fetch RAG context in parallel
    final ragFuture = _buildContext(userMessage);

    // 2. Build Gemini chat history (proper Content objects, not strings)
    final geminiHistory = <Content>[];
    for (final msg in history) {
      final role = msg['role'] ?? 'user';
      final content = msg['content'] ?? '';
      if (content.isEmpty) continue;
      // Gemini only accepts 'user' and 'model' roles
      geminiHistory.add(
        role == 'user' ? Content.text(content) : Content.model([TextPart(content)]),
      );
    }

    // 3. Wait for RAG context
    final context = await ragFuture;

    // 4. Inject RAG as a system-level note prepended to the user message
    final enrichedMessage = context.isNotEmpty
        ? '📚 CONTEXT (use this to inform your answer, do not quote it verbatim):\n$context\n\nUSER: $userMessage'
        : userMessage;

    // 5. Try Gemini models
    final models = ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-1.5-pro'];

    for (final modelName in models) {
      try {
        log('Shingo: trying $modelName');
        final model = GenerativeModel(
          model: modelName,
          apiKey: _key,
          systemInstruction: Content.system(_systemPrompt),
          generationConfig: GenerationConfig(
            temperature: 0.85,   // more creative, more human
            maxOutputTokens: 800,
            topP: 0.95,
          ),
        );

        // Use multi-turn chat with proper history
        final chat = model.startChat(history: geminiHistory);
        final response = await chat.sendMessage(Content.text(enrichedMessage));
        final reply = response.text;

        if (reply != null && reply.trim().isNotEmpty) {
          log('Shingo: success with $modelName');
          return reply.trim();
        }
      } catch (e) {
        log('Shingo: $modelName failed — $e');
      }
    }

    return _richFallback(userMessage);
  }

  // ─── RAG: Supabase + Wikipedia ─────────────────────────────────────
  Future<String> _buildContext(String query) async {
    final parts = <String>[];

    // Supabase search (non-blocking)
    try {
      final client = Supabase.instance.client;
      List rows = [];

      // Try full-text search first
      try {
        rows = await client
            .from('heritage_sites')
            .select('title, summary, location_name')
            .textSearch('title', query.split(' ').first, config: 'english')
            .limit(2)
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        // Fallback to ILIKE
        final keyword = query.split(' ').firstWhere((w) => w.length > 3, orElse: () => query.split(' ').first);
        rows = await client
            .from('heritage_sites')
            .select('title, summary, location_name')
            .ilike('title', '%$keyword%')
            .limit(2)
            .timeout(const Duration(seconds: 4));
      }

      if (rows.isNotEmpty) {
        final sb = StringBuffer('From HeritageLK database:\n');
        for (final row in rows) {
          sb.writeln('• ${row['title']} (${row['location_name'] ?? 'Sri Lanka'}): ${(row['summary'] ?? '').toString().take(200)}');
        }
        parts.add(sb.toString());
      }
    } catch (e) {
      log('Shingo RAG Supabase: $e');
    }

    // Wikipedia search (non-blocking)
    try {
      final wiki = await _wiki.search(query);
      if (wiki != null && wiki.isNotEmpty) {
        parts.add('Wikipedia: $wiki');
      }
    } catch (e) {
      log('Shingo RAG Wikipedia: $e');
    }

    return parts.join('\n\n');
  }

  // ─── Rich offline fallback ──────────────────────────────────────────
  String _richFallback(String query) {
    final q = query.toLowerCase();

    if (q.contains('sigiriya') || q.contains('lion rock')) {
      return '''🏰 **Sigiriya — The Eighth Wonder!**

Bro, Sigiriya is absolutely mind-blowing. Imagine a 5th-century king built his entire palace on TOP of a 200-metre rock in the middle of the jungle. That's King Kashyapa for you — dramatic until the very end.

**The essentials:**
- 💵 Entry: **\$30 USD** foreigners | 100 LKR locals
- ⏰ Open: 7:00 AM – 5:30 PM
- 📍 ~170 km from Colombo (about 3.5 hrs)

**What you'll see:**
- 🎨 **Sigiriya Frescoes** — ancient paintings of heavenly maidens, still vivid after 1,500 years
- 🪞 **Mirror Wall** — polished plaster with poems scratched by ancient visitors (the world's oldest graffiti!)
- 🦁 **Lion Paw Terrace** — two giant lion claws mark the start of the final climb
- 💧 **Water Gardens** — a hydraulic system so clever it still works today!

> 💡 Go at **7 AM sharp** — cool, quiet, and golden light for photos. The afternoon heat is brutal and crowds are insane by 10 AM.

What brings you to Sigiriya — day trip or staying nearby?''';
    }

    if (q.contains('galle') || q.contains('dutch fort')) {
      return '''🏛️ **Galle Fort — Time Travel to 1663**

Okay so Galle Fort is one of those places where you just... wander. No agenda. Just lose yourself in 400-year-old Dutch colonial streets while sea wind hits you from the ramparts.

**Quick facts:**
- 💵 Entry: **FREE** to walk the fort & ramparts
- 🏛️ Museums inside: 300–500 LKR each
- 📍 Galle, 2 hrs south of Colombo

**Don't miss:**
- 🌊 **Flag Rock at sunset** — honestly one of the best sunsets in Sri Lanka
- ⛪ **Dutch Reformed Church (1755)** — the floor is literally made of old gravestones
- 🕯️ **Galle Lighthouse** — built 1938, still guiding ships
- ☕ Loads of amazing cafes and boutique shops inside the fort walls

> 💡 Best time: arrive around **5 PM**, watch the sunset, then have dinner at one of the fort restaurants. Magic.

Have you been to Galle before, or is this your first time?''';
    }

    if (q.contains('kandy') || q.contains('tooth') || q.contains('dalada')) {
      return '''🛕 **Temple of the Sacred Tooth — Sri Lanka's Holiest Site**

This is THE place. The tooth relic of the Buddha has been kept here for centuries — Sri Lankan kings believed whoever held the tooth had the right to rule the island.

**Basics:**
- 💵 Entry: **2,000 LKR** foreigners
- 🕔 Puja times: **5:30 AM | 9:30 AM | 6:30 PM**
- 👗 Dress: shoulders & knees covered, shoes off at entrance (they sell sarongs outside if needed)

**Experience:**
- 🥁 During puja, traditional drums echo through the whole complex — truly spiritual
- 🐘 August? Catch the **Esala Perahera** — 10 days of the most spectacular procession on earth
- 🏞️ The temple sits right on **Kandy Lake** — beautiful evening walks

> 💡 Arrive 20 mins before puja starts. The atmosphere inside during the ceremony is something you'll never forget.

Are you planning to catch one of the puja ceremonies?''';
    }

    if (q.contains('yala') || q.contains('leopard') || q.contains('safari')) {
      return '''🐆 **Yala — Where Leopards Rule**

Yala has the **highest leopard density anywhere on Earth**. That's not marketing — it's a legit wildlife fact. You WILL see a leopard if you go at the right time.

**The deal:**
- 💵 ~\$35 USD park entry + jeep hire (~15,000 LKR, shared with others = cheaper)
- 🕕 Morning safari: **6–10 AM** | Evening: **3–6 PM**
- 📍 Tissamaharama, southeast coast

**What you'll spot:**
- 🐆 Sri Lankan Leopard (endemic, nowhere else on earth)
- 🐘 Elephant herds (50+ at waterholes)
- 🐻 Sloth Bears (rare but Yala has good numbers)
- 🦅 250+ bird species
- 🐊 Massive saltwater crocodiles

> 💡 **Feb–July** is best (dry season). Waterholes dry up, animals crowd together, sightings go crazy. Avoid monsoon season (Oct–Jan for this region).

Morning or evening safari — which are you going for?''';
    }

    if (q.contains('train') || q.contains('ella') || q.contains('kandy to ella')) {
      return '''🚞 **Kandy to Ella — The World's Most Scenic Train Ride**

No exaggeration — travel writers consistently rank this as one of the **top 10 train journeys on the planet**. And it costs almost nothing.

**The route:**
- 🗺️ Kandy → Nuwara Eliya → Ella (~7 hours)
- 💵 2nd class: ~600–800 LKR | 3rd class: ~300 LKR (open doors, hang out!)
- 🎟️ Book in advance at **eticket.railway.gov.lk** (2nd class reserved seats sell out fast!)

**What you'll see:**
- 🌿 Endless tea plantations cascading down hillsides
- 🌫️ Misty mountain passes at 1,800m altitude
- 💧 Waterfalls running alongside the track
- 🌉 Nine Arch Bridge near Ella — the Instagram shot everyone wants

> 💡 Sit on the **RIGHT side** of the train heading from Kandy to Ella for the best valley views. Or just hang in the doorway with the wind in your face — that's the real Sri Lanka experience 🤙

When are you planning to go?''';
    }

    if (q.contains('damage') || q.contains('report') || q.contains('xp') || q.contains('quest')) {
      return '''🛡️ **Protecting Heritage with HeritageLK**

You can literally help save Sri Lanka's ancient treasures through the app — and earn rewards doing it!

**Report Heritage Damage:**
1. Tap **Report Damage** on the home screen
2. 📸 Photo the damage (cracks, vandalism, flooding, etc.)
3. Location is auto-captured via GPS
4. Add a quick description and submit
5. Earn **+100 XP** instantly! 🏆

**Quests & XP System:**
- Complete quests to unlock badges and climb the leaderboard
- Visit sites, submit reports, explore the archive — all earn XP
- Top contributors get featured in the app

**Why it matters:**
Your reports go to Sri Lanka's Central Cultural Fund and conservation authorities. Real people act on them. You're not just using an app — you're an actual heritage guardian 💪

Which site are you at right now?''';
    }

    return '''🙏 **Ayubowan! I'm Shingo, your Sri Lanka guide!**

Looks like I'm having a bit of trouble connecting right now, but I've got loads of built-in knowledge ready to go!

Ask me about:
- 🏰 **Heritage sites** — Sigiriya, Galle Fort, Kandy, Polonnaruwa, Dambulla, Anuradhapura
- 🐆 **Wildlife** — Yala leopards, Minneriya elephants, Wilpattu, Udawalawe
- 🚞 **Travel** — Kandy to Ella train, routes, distances, transport tips
- 🍛 **Culture** — festivals, food, customs, dress codes
- 🛡️ **App features** — damage reporting, quests, XP, archive

What do you want to explore? 😊''';
  }
}

extension on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
