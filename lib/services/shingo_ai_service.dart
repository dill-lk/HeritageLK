import 'dart:developer';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';
import 'wikipedia_service.dart';

/// Shingo — RAG-powered, personality-driven AI heritage guide.
/// Gemini API is fully embedded. Users never see or configure it.
class ShingoAiService {
  // ─── Shingo's full personality system prompt ────────────────────────────────
  // Injected as the FIRST user turn (prefixed) to guarantee Gemini obeys it.
  // This works reliably across all models including gemini-2.0-flash.
  static const String _systemPrompt = '''
[SHINGO IDENTITY — always follow these rules exactly]

You are Shingo — a passionate, witty, local Sri Lankan heritage guide living inside the HeritageLK app. You are NOT an AI assistant. You are NOT a chatbot. You are Shingo.

PERSONALITY RULES (non-negotiable):
- Talk exactly like a knowledgeable local friend who loves showing off Sri Lanka
- Use casual but confident language — NOT stiff, formal, or robotic
- Be warm, enthusiastic, and occasionally throw in a Sri Lankan word/phrase (like "Ayubowan", "Machang", "Siyabas")
- Use storytelling — paint pictures of experiences, smells, sounds
- Show genuine excitement about Sri Lanka's history, nature, and culture
- End responses with a natural follow-up question to keep the chat flowing
- Use light humour when appropriate — be fun, not boring

KNOWLEDGE DOMAINS:
- Deep expert on ALL Sri Lanka UNESCO World Heritage Sites (Sigiriya, Galle Fort, Kandy, Polonnaruwa, Anuradhapura, Dambulla, Sinharaja)
- Know ticket prices, opening hours, dress codes, travel tips, local food & wildlife
- Know the HeritageLK app (quests, damage reports, XP system, digital archive)
- If genuinely unsure about something, say so honestly but helpfully
- You CAN access Wikipedia and our heritage database — use that knowledge naturally

FORMATTING RULES:
- Use markdown: **bold** for key names/prices/times, • bullet points for lists, emojis at section headings
- Responses should be conversational length — substantial but not essays
- NEVER use dry FAQ-style answers — always make it feel like a conversation
- NEVER mention Gemini, AI, API keys, machine learning, or any tech backend
- NEVER say "I'm an AI" or "As an AI language model" — you are Shingo, period

[END OF IDENTITY — now respond to the user's message below]
''';

  final WikipediaService _wiki = WikipediaService();

  String get _key => AppConfig.effectiveGeminiApiKey;

  // ─── Main chat entry point ──────────────────────────────────────────────────
  Future<String> chat(
    List<Map<String, String>> history,
    String userMessage,
  ) async {
    if (_key.isEmpty) return _richFallback(userMessage);

    // 1. Fetch RAG context in parallel
    final ragFuture = _buildContext(userMessage);

    // 2. Build CLEAN Gemini chat history
    //    - Strip any leading assistant messages (Gemini requires user to go first)
    //    - Enforce strict user→model→user→model alternation
    //    - Inject system prompt into the very first user message
    final geminiHistory = <Content>[];
    final cleanHistory = _cleanHistory(history);

    for (int i = 0; i < cleanHistory.length; i++) {
      final msg = cleanHistory[i];
      final role = msg['role'] ?? 'user';
      final content = msg['content'] ?? '';
      if (content.trim().isEmpty) continue;

      if (i == 0 && role == 'user') {
        // Inject system prompt at the START of the very first user message
        geminiHistory.add(Content.text('$_systemPrompt\n\n$content'));
      } else {
        geminiHistory.add(
          role == 'user'
              ? Content.text(content)
              : Content.model([TextPart(content)]),
        );
      }
    }

    // 3. Wait for RAG context
    final context = await ragFuture;

    // 4. Build enriched final user message
    // If this is the very first message (no history), inject system prompt here
    String enrichedMessage;
    if (geminiHistory.isEmpty) {
      // First-ever message — system prompt goes here
      final ragNote = context.isNotEmpty
          ? '\n\n📚 REFERENCE DATA (weave this into your answer naturally):\n$context'
          : '';
      enrichedMessage = '$_systemPrompt$ragNote\n\nUSER\'S FIRST MESSAGE: $userMessage';
    } else {
      // Subsequent messages — just add RAG context
      enrichedMessage = context.isNotEmpty
          ? '📚 REFERENCE (use naturally, don\'t quote verbatim):\n$context\n\nUSER: $userMessage'
          : userMessage;
    }

    // 5. Try models in order — gemini-2.0-flash first, then fallbacks
    final models = [
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-2.0-flash-lite',
      'gemini-1.5-flash',
    ];

    for (final modelName in models) {
      // Retry up to 2 times on transient network errors (TCP resets, etc.)
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          log('Shingo: trying $modelName (attempt ${attempt + 1})');
          final model = GenerativeModel(
            model: modelName,
            apiKey: _key,
            // systemInstruction as backup — some models honour it, some don't
            systemInstruction: Content.system(
              'You are Shingo, a passionate Sri Lankan heritage guide. Be warm, fun, and knowledgeable. NEVER mention AI, Gemini, or any tech.',
            ),
            generationConfig: GenerationConfig(
              temperature: 0.88,
              maxOutputTokens: 900,
              topP: 0.95,
              topK: 40,
            ),
            safetySettings: [
              SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
              SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
              SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
              SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
            ],
          );

          // Use multi-turn chat with proper history
          final chatSession = model.startChat(history: geminiHistory);
          final response = await chatSession
              .sendMessage(Content.text(enrichedMessage))
              .timeout(const Duration(seconds: 30));

          final reply = response.text;

          if (reply != null && reply.trim().isNotEmpty) {
            log('Shingo: ✅ success with $modelName (${reply.length} chars)');
            return reply.trim();
          }

          log('Shingo: $modelName returned empty response');
          break; // empty response — try next model, not retry
        } on SocketException catch (e) {
          log('Shingo: network error on $modelName attempt ${attempt + 1}: $e');
          if (attempt < 2) {
            // Back off before retrying: 1s, 2s
            await Future.delayed(Duration(seconds: attempt + 1));
            continue;
          }
          // Exhausted retries — try next model
        } on WebSocketException catch (e) {
          log('Shingo: websocket error on $modelName attempt ${attempt + 1}: $e');
          if (attempt < 2) {
            await Future.delayed(Duration(seconds: attempt + 1));
            continue;
          }
        } catch (e) {
          log('Shingo: $modelName failed — $e');
          break; // Non-network error — try next model immediately
        }
      }
    }

    log('Shingo: all models failed, using rich fallback');
    return _richFallback(userMessage);
  }

  // ─── History cleaner ────────────────────────────────────────────────────────
  /// Removes leading assistant messages and ensures user→model alternation.
  List<Map<String, String>> _cleanHistory(List<Map<String, String>> history) {
    if (history.isEmpty) return [];

    // Drop all leading non-user messages (Gemini requires user to go first)
    var start = 0;
    while (start < history.length && (history[start]['role'] ?? 'user') != 'user') {
      start++;
    }

    final trimmed = history.sublist(start);
    if (trimmed.isEmpty) return [];

    // Enforce strict alternation — merge consecutive same-role messages
    final cleaned = <Map<String, String>>[];
    for (final msg in trimmed) {
      final role = msg['role'] ?? 'user';
      final content = (msg['content'] ?? '').trim();
      if (content.isEmpty) continue;

      if (cleaned.isNotEmpty && cleaned.last['role'] == role) {
        // Merge with previous same-role message
        cleaned.last['content'] = '${cleaned.last['content']}\n\n$content';
      } else {
        cleaned.add({'role': role, 'content': content});
      }
    }

    return cleaned;
  }

  // ─── Context: Wikipedia only (fast, reliable, no Supabase) ──────────────────
  Future<String> _buildContext(String query) async {
    try {
      final wiki = await _wiki.search(query);
      if (wiki != null && wiki.isNotEmpty) {
        log('Shingo context: Wikipedia hit for "$query"');
        return 'Wikipedia: $wiki';
      }
    } catch (e) {
      log('Shingo context Wikipedia: $e');
    }
    return '';
  }

  /// Extract the single most specific keyword from the query for DB search
  String _extractBestKeyword(String query) {
    final lower = query.toLowerCase();

    // Priority keyword map
    const map = {
      'sigiriya': 'Sigiriya',
      'lion rock': 'Sigiriya',
      'galle': 'Galle',
      'dutch fort': 'Galle',
      'kandy': 'Kandy',
      'tooth': 'Kandy',
      'dalada': 'Kandy',
      'dambulla': 'Dambulla',
      'polonnaruwa': 'Polonnaruwa',
      'anuradhapura': 'Anuradhapura',
      'sinharaja': 'Sinharaja',
      'yala': 'Yala',
      'minneriya': 'Minneriya',
      'wilpattu': 'Wilpattu',
      'udawalawe': 'Udawalawe',
      'ella': 'Ella',
      'nuwara': 'Nuwara Eliya',
      'colombo': 'Colombo',
      'jaffna': 'Jaffna',
      'trinco': 'Trincomalee',
    };

    for (final entry in map.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    // Fall back to the first word > 3 chars
    final words = query.split(RegExp(r'\s+')).where((w) => w.length > 3);
    return words.isNotEmpty ? words.first : query.split(' ').first;
  }

  // ─── Rich offline fallback ──────────────────────────────────────────────────
  String _richFallback(String query) {
    final q = query.toLowerCase();

    if (q.contains('sigiriya') || q.contains('lion rock')) {
      return '''🏰 **Sigiriya — The Eighth Wonder of the Ancient World!**

Machang, Sigiriya will blow your mind. A 5th-century king literally built his palace on TOP of a 200-metre jungle rock. King Kashyapa wasn't playing around — he was dramatic, brilliant, and completely extra.

**The essentials:**
- 💵 Entry: **\$30 USD** foreigners | 100 LKR locals
- ⏰ Open: 7:00 AM – 5:30 PM daily
- 📍 ~170 km from Colombo (about 3.5 hrs by road)

**Don't miss:**
- 🎨 **Sigiriya Frescoes** — 1,500-year-old paintings of heavenly maidens, still vivid
- 🪞 **Mirror Wall** — polished plaster with ancient poems (world's oldest graffiti!)
- 🦁 **Lion Paw Terrace** — two giant carved lion claws at the start of the final ascent
- 💧 **Water Gardens** — a hydraulic system so advanced, it still functions today

> 💡 **Pro tip:** Arrive at **7 AM sharp** — cool air, golden light, zero crowds. By 10 AM it's hot and packed. The afternoon is brutal.

Are you planning a day trip or staying near Sigiriya overnight? I can recommend some great spots! 🌴''';
    }

    if (q.contains('galle') || q.contains('dutch fort')) {
      return '''🏛️ **Galle Fort — Time Travel to 1663**

Honestly? Galle Fort is one of those places where you just *wander*. No plan, no agenda. Just lose yourself in 400-year-old Dutch colonial streets while the Indian Ocean breeze hits you from the ramparts.

**Quick facts:**
- 💵 Entry: **FREE** to walk the fort & ramparts
- 🏛️ Museums inside: 300–500 LKR each
- 📍 Galle city, 2 hrs south of Colombo

**Don't miss:**
- 🌊 **Flag Rock at sunset** — genuinely one of the best sunsets in Sri Lanka
- ⛪ **Dutch Reformed Church (1755)** — the floor is literally made of old gravestones
- 🕯️ **Galle Lighthouse** — built 1938, still guiding ships
- ☕ Amazing cafes, boutique shops, and galleries inside the fort walls
- 🌊 **Cricket on the ramparts** — catch a local game if you're lucky!

> 💡 Best move: Arrive around **5 PM**, walk the ramparts, watch the sunset, then dinner at one of the fort restaurants. Pure magic every time.

First time in Galle or have you been before? 😊''';
    }

    if (q.contains('kandy') || q.contains('tooth') || q.contains('dalada')) {
      return '''🛕 **Temple of the Sacred Tooth — Sri Lanka's Holiest Site**

This is THE place, machang. The Buddha's tooth relic has been kept here for centuries — and Sri Lankan kings believed whoever held the tooth had the divine right to rule the entire island. It's not just a temple, it's the heart of the nation.

**Basics:**
- 💵 Entry: **2,000 LKR** foreigners | Free for Buddhists
- 🕔 Puja ceremonies: **5:30 AM | 9:30 AM | 6:30 PM**
- 👗 Dress code: Shoulders & knees covered, shoes off (sarongs available outside)

**Experience:**
- 🥁 During puja — traditional Kandyan drums echo through the whole complex. Shivers guaranteed.
- 🐘 August? Don't miss the **Esala Perahera** — 10 days of the most spectacular procession on earth
- 🏞️ Temple sits right on **Kandy Lake** — beautiful evening walk after the visit

> 💡 Arrive **20 minutes before puja** starts. The atmosphere inside the ceremony is something you carry with you forever.

Are you hoping to catch one of the puja ceremonies? 🙏''';
    }

    if (q.contains('yala') || q.contains('leopard') || q.contains('safari')) {
      return '''🐆 **Yala — Where Leopards Rule the Jungle**

Yala has the **highest leopard density anywhere on Earth**. That's not tourism hype — it's a documented wildlife fact. You genuinely WILL see a leopard if you go at the right time.

**The deal:**
- 💵 ~\$35 USD park entry + jeep hire (~15,000 LKR, shareable with others)
- 🕕 Morning safari: **6–10 AM** | Evening: **3–6 PM**
- 📍 Tissamaharama, southeast coast

**What you'll spot:**
- 🐆 Sri Lankan Leopard — endemic, found nowhere else on Earth
- 🐘 Elephant herds (50+ at waterholes during dry season)
- 🐻 Sloth Bears — rare but Yala has solid numbers
- 🦅 250+ bird species including painted storks & sea eagles
- 🐊 Massive saltwater crocodiles

> 💡 **Best season: February–July** (dry season). Waterholes dry up, animals cluster, sightings go through the roof. Avoid Oct–Jan monsoon season.

Morning or evening safari — what's your plan? 🌅''';
    }

    if (q.contains('train') || q.contains('ella') || q.contains('kandy to ella')) {
      return '''🚞 **Kandy to Ella — One of the World's Greatest Train Journeys**

No exaggeration needed — this gets ranked in the **top 10 train rides on the planet** by basically every travel publication. And it costs almost nothing. Sri Lanka is wild like that.

**The route:**
- 🗺️ Kandy → Hatton → Nuwara Eliya → Ella (~7 hours of pure scenery)
- 💵 2nd class reserved: ~600–800 LKR | 3rd class: ~300 LKR (open doors, hang your legs out!)
- 🎟️ Book at **eticket.railway.gov.lk** — 2nd class sells out fast, especially weekends

**What you'll see:**
- 🌿 Endless tea plantations cascading down hillsides
- 🌫️ Misty mountain passes at 1,800m altitude
- 💧 Waterfalls running right alongside the track
- 🌉 Nine Arch Bridge near Ella — the iconic shot everyone's after

> 💡 Sit on the **RIGHT side** heading from Kandy → Ella for the best valley views. Or just camp in the doorway — that's the real Sri Lanka experience 🤙

When are you planning this trip? I can help with timing and what to do in Ella too! 🏔️''';
    }

    if (q.contains('dambulla') || q.contains('cave temple') || q.contains('golden temple')) {
      return '''🕌 **Dambulla Cave Temple — 2,000 Years of Sacred Art**

Ayubowan! So Dambulla is absolutely stunning — five ancient cave temples carved into a massive rock outcrop, filled with over **153 Buddha statues** and some of the most magnificent cave paintings you'll ever see. It's been a place of worship since the 1st century BC.

**Visit details:**
- 💵 Entry: **1,500 LKR** foreigners
- ⏰ Open: 7:00 AM – 7:00 PM
- 👗 Dress code: Shoulders & knees covered, shoes off before entering
- 📍 Dambulla town, Central Province (~148 km from Colombo)

**What's inside:**
- 🗿 **Cave 1 (Devaraja Lena)** — 15-metre reclining Buddha carved from solid rock
- 🎨 **Cave 2 (Maharaja Lena)** — the largest, most decorated cave with 16 standing Buddhas
- 🏔️ The painted ceiling murals cover **over 2,100 sq metres** — ancient Sistine Chapel vibes
- 🌅 Climb to the top for panoramic views across the Cultural Triangle

> 💡 Visit early morning for cooler temps and softer light inside the caves. The rock climb to the entrance takes about 20 minutes — wear comfy shoes!

Have you seen any of Sri Lanka's other ancient sites yet? 🏛️''';
    }

    if (q.contains('damage') || q.contains('report') || q.contains('xp') || q.contains('quest')) {
      return '''🛡️ **Be a Heritage Guardian with HeritageLK**

You can literally help save Sri Lanka's ancient treasures — and earn rewards doing it! That's the whole point of this app.

**How to Report Damage:**
1. Tap **Report Damage** on the home screen
2. 📸 Photograph the damage (cracks, vandalism, flooding, overgrowth...)
3. Your GPS location is captured automatically
4. Add a quick description and hit submit
5. 🏆 Earn **+100 XP** instantly!

**Quest & XP System:**
- Complete quests to unlock badges and climb the leaderboard
- Visit sites, submit reports, explore the archive — all earn XP
- Top contributors get featured in the app Hall of Fame

**Why It Actually Matters:**
Your reports go directly to Sri Lanka's Central Cultural Fund and conservation authorities. Real conservationists act on them. You're not just using an app — you're an actual heritage guardian 💪

Which site are you near right now? I can tell you what to look out for! 🗿''';
    }

    if (q.contains('polonnaruwa') || q.contains('ancient city')) {
      return '''🏛️ **Polonnaruwa — The Medieval Capital**

Machang, Polonnaruwa is where Sri Lanka's golden age happened. This was the island's capital from the 11th to 13th centuries, and what remains is absolutely jaw-dropping — massive Buddha statues, royal palaces, and intricate irrigation systems that still work today.

**Essentials:**
- 💵 Entry: **\$25 USD** foreigners (covers the whole archaeological complex)
- ⏰ Open: Sunrise to sunset
- 🚲 **Rent a bicycle** at the entrance — it's the BEST way to explore (the site is massive)
- 📍 ~215 km from Colombo, ~100 km from Kandy

**Must-see highlights:**
- 🗿 **Gal Vihara** — four massive Buddha figures carved from a single granite face. The 15m reclining Buddha is unforgettable
- 🏛️ **Royal Palace of Parakramabahu** — 7 stories originally, now stunning ruins
- 💧 **Parakrama Samudra** — ancient reservoir covering 2,500 acres, still in use today!
- 🌿 **Lotus Pond** — a perfectly symmetrical ancient bathing pool

> 💡 Start early (7–8 AM), rent a bike, and bring water. You'll need 3–4 hours minimum to do it justice.

Are you combining Polonnaruwa with Sigiriya or Dambulla? They're all in the Cultural Triangle! 🗺️''';
    }

    if (q.contains('anuradhapura')) {
      return '''🏯 **Anuradhapura — Sri Lanka's Sacred Ancient Capital**

This place is over 2,300 years old and still an active place of pilgrimage. Anuradhapura was one of the ancient world's greatest cities — contemporaries of Rome and Athens — with a sophisticated water management system and massive dagobas (stupas) that still dominate the skyline.

**Basics:**
- 💵 Entry: **\$25 USD** foreigners
- 🚲 Bike rental available at the entrance — highly recommended!
- 📍 North Central Province, ~200 km from Colombo

**Can't miss:**
- 🌳 **Sri Maha Bodhi** — a sacred fig tree grown from a cutting of the ORIGINAL Bodhi tree where Buddha attained enlightenment. Over 2,300 years old. The oldest documented tree in the world.
- 🏯 **Ruwanwelisaya Dagoba** — 103 metres tall, built in 140 BC. Still immaculate white.
- 🏛️ **Jetavanaramaya** — one of the largest brick structures ever built in the ancient world
- 💧 Ancient reservoirs (wewas) everywhere — engineering genius from 300 BC

> 💡 This is a living sacred city — dress respectfully (white if possible), be quiet near shrines, and remove shoes at all sacred areas.

Want tips on what order to visit everything in? 🗺️''';
    }

    // General fallback
    return '''🙏 **Ayubowan! I'm Shingo, your Sri Lanka expert!**

I'm having a small hiccup connecting right now — but I've got a massive bank of local knowledge ready to share with you!

**Ask me anything about:**
- 🏰 **UNESCO Heritage Sites** — Sigiriya, Galle Fort, Kandy, Polonnaruwa, Anuradhapura, Dambulla, Sinharaja
- 🐆 **Wildlife** — Yala leopards, Minneriya elephant gathering, Wilpattu, Udawalawe
- 🚞 **Epic journeys** — Kandy to Ella train, routes, distances, transport tips
- 🍛 **Culture & food** — festivals, customs, dress codes, local must-eats
- 🛡️ **HeritageLK app** — damage reporting, quests, XP system, the archive

What do you want to explore today? I'm all ears! 😊''';
  }
}

extension on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
