# HeritageLK — Feature Proposals (Selected for Deep Dive)

> This document expands on four features marked as **"good"** during the initial brainstorm.  
> Each section covers **why it matters**, **what it does**, **how to build it** (tech plan), **data models**, **UI/UX hooks**, and **hackathon demo strategy**.  
> All designs respect the app's existing architecture: Flutter, Supabase, Gemini AI, offline-first, and the dark heritage theme.

---

## 1. Heritage Audio Guides (TTS-based)

### Why
- Visitors at Sigiriya, Galle Fort, Anuradhapura, etc., often read a plaque and move on.  
- Audio narration keeps eyes on the site, works for visually-impaired users, and adds emotional depth.  
- TTS (text-to-speech) needs **zero audio storage** — scripts are tiny text files.

### What it does
- Every heritage site in `_allSites` (explore_screen.dart:40-107) gets a **"Listen" button**.
- Tap → bottom-sheet player appears with:
  - Play / pause / 0.8×–1.5× speed
  - Language picker: **English / Sinhala / Tamil**
  - Optional: download for offline (caches rendered MP3 or just the script)
- Scripts are 60–120 seconds: history, key details, what to look for, one local legend.

### Tech plan
| Piece | Choice | Rationale |
|-------|--------|-----------|
| TTS engine | `flutter_tts` | Works Android/iOS, supports `si-LK` & `ta-LK` via platform voices |
| Script storage | JSON assets + optional Supabase Storage | `assets/audio_scripts/{siteId}_{lang}.json` — ~2 KB each |
| Offline cache | `getApplicationDocumentsDirectory()` | Save rendered MP3 if user taps "Download" |
| UI | Reusable `AudioGuidePlayer` widget | Drop into `_NearbyCard`, `_archiveTile`, site detail sheets |

**New dependency:** `flutter_tts: ^4.0.0`

### Data model (minimal)
```dart
class AudioScript {
  final String siteId;
  final String langCode;      // 'en', 'si', 'ta'
  final String title;
  final String bodyText;      // plain text for TTS
  final Duration approxDuration;
}
```

### Integration points
1. **Explore screen** — add speaker icon to each marker popup and `_bottomInfoCard`.
2. **Archive detail** — "Listen to history" button under the hero image.
3. **Scanner/Journal** — when user saves a visit, offer "Hear about this site".
4. **Home screen** — "Audio Guide of the Day" card linking to a featured site.

### Hackathon demo script
1. Pre-bundle **one high-quality Sinhala script for Sigiriya** (recorded via TTS at build time or live).
2. During pitch: open Explore → tap Sigiriya marker → hit "Listen" → audio plays instantly.
3. Mention: *"70 sites × 3 languages = 210 scripts. Total asset size < 500 KB. Zero backend cost."*

### Constraints & mitigations
| Risk | Mitigation |
|------|------------|
| Platform TTS voice quality varies | Note in pitch: "Production can swap to ElevenLabs/AWS Polly for studio voices — same API." |
| Sinhala/Tamil not on all devices | Graceful fallback: show script text with "Copy" button if voice unavailable. |
| Battery drain | TTS is lightweight; player auto-pauses when screen locks. |

---

## 2. Digital Heritage Passport (Local-First Gamification)

### Why
- The app already has **points, ranks, quests, leaderboards** (`quests_screen.dart`, `home_screen.dart`).
- A **visual passport** turns abstract points into a collectible, shareable artifact.
- **Offline-only** = zero database cost, works at remote sites (Sinharaja, Knuckles, Jaffna).

### What it does
- New **"Passport" tab** in Profile screen (or bottom-nav item).
- Grid of **stamp slots** — one per heritage site (70+ from `_allSites`).
- A slot fills when user:
  - **Visits** (GPS geofence ≤ 200 m from site coords)
  - **Scans** via Camera/Journal screen
  - **Completes** a related quest
- Filled stamp shows: site icon, visit date, method badge (📍 GPS / 📸 Scan / 🏆 Quest).
- **Tiers**: Bronze (5), Silver (15), Gold (35), **Heritage Legend** (all 70+).
- **One-tap share** → generates a PNG card (passport cover + tier + stamp count) for Instagram/WhatsApp.

### Tech plan
| Piece | Choice | Rationale |
|-------|--------|-----------|
| Storage | `shared_preferences` + local JSON (`passport_v1.json`) | No Supabase needed; survives reinstall if user backs up file |
| Geofence check | Reuse `LocationService.getCurrentPosition()` + Haversine distance | Already in `home_screen.dart:33-42` |
| Stamp UI | `AnimatedContainer` + `Lottie` (optional) for "stamp press" effect | Matches existing heritage theme |
| Share image | `screenshot` + `share_plus` packages | Native share sheet, no backend |

**New dependencies:**
```yaml
shared_preferences: ^2.3.2   # already in pubspec.yaml
screenshot: ^3.0.0
share_plus: ^10.0.0
lottie: ^3.1.0               # optional, for delight
```

### Data model (local-only)
```dart
class PassportStamp {
  final String siteId;
  final String siteName;
  final DateTime earnedAt;
  final String method;        // 'gps' | 'scan' | 'quest'
  final String? photoPath;    // optional: journal photo if method == 'scan'
}

class HeritagePassport {
  final List<PassportStamp> stamps;
  int get tierIndex => (stamps.length / 5).floor().clamp(0, 3);
  String get tierName => ['Bronze', 'Silver', 'Gold', 'Legend'][tierIndex];
  bool get isLegend => stamps.length >= 70;
}
```

### Integration points
1. **Home screen** — after `_loadGpsLocation()`, check nearby sites → auto-grant GPS stamp.
2. **Scanner screen** — when `_captureVisit()` succeeds, grant Scan stamp for nearest site.
3. **Quests screen** — on `_flowStep == 'completed'`, grant Quest stamp for that quest's site.
4. **Profile screen** — new "View Passport" button → pushes `PassportScreen`.

### Hackathon demo script
1. Pre-seed **6 stamps** (Sigiriya, Galle Fort, Temple of Tooth, Nine Arches, Yala, Adam's Peak) in the demo build's `shared_preferences`.
2. Open Profile → tap "My Passport" → show animated grid with 6 golden stamps.
3. Tap "Share" → generates a beautiful PNG card → "Look, I'm a **Silver** explorer!"
4. Say: *"Zero cloud cost. Works on a plane. Works in Sinharaja rainforest. Your heritage journey lives on your phone."*

### Constraints & mitigations
| Risk | Mitigation |
|------|------------|
| GPS spoofing / fake stamps | Demo only — production adds cooldown + distance threshold + optional photo proof |
| No cloud backup | Optional: if `AppConfig.hasSupabase`, mirror stamps to `user_passports` table (1 row per user) |
| Storage bloat | 70 stamps × ~200 bytes = 14 KB. Negligible. |

---

## 3. Heritage Feed (Community Social Layer)

### Why
- Heritage preservation is **communal** — locals, tourists, historians all contribute.
- A feed turns the app from a **tool** into a **platform** → higher retention, UGC for the archive.
- Reuses existing Supabase auth + storage + realtime.

### What it does
- New **Feed tab** (between Home and Explore in bottom nav).
- Chronological cards, each linking to a heritage site:
  - **Journal share** — photo + notes from Scanner screen ("First time at Ritigala — misty and magical 🌫️")
  - **Damage report update** — "Reported cracks at Galle Fort wall → status: In Review"
  - **Archive contribution** — "Added my grandmother's Ambalangoda mask-making story"
  - **Quest completion** — "Just earned the Fort Guardian badge! 🏰"
- Light engagement: ❤️ like, 💬 comment count (no full comment thread v1).
- **Moderation**: keyword filter + admin review queue (reuse `ReportAdminScreen` pattern).

### Tech plan
| Piece | Choice | Rationale |
|-------|--------|-----------|
| DB table | `heritage_feed` (see schema below) | Single table, polymorphic `type` column |
| Realtime | Supabase Realtime `INSERT` subscription | Live feed without polling |
| Images | Existing `heritage-media` bucket | Reuse uploader from `scanner_screen.dart` |
| Auth | Supabase Auth (already integrated) | `user_id` FK, RLS policies |
| Pagination | Cursor-based (`created_at`, `limit: 20`) | Smooth infinite scroll |

**New dependencies:** none (uses existing `supabase_flutter`, `go_router` for navigation).

### Database schema
```sql
create table heritage_feed (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  type text not null check (type in ('journal','damage','archive','quest')),
  site_id text,                          -- links to _allSites name or archive id
  content text not null,                 -- caption / story
  image_url text,                        -- optional, from heritage-media bucket
  likes int default 0,
  created_at timestamptz default now()
);

-- RLS
alter table heritage_feed enable row level security;
create policy "public read" on heritage_feed for select using (true);
create policy "own insert" on heritage_feed for insert with check (auth.uid() = user_id);
create policy "own update" on heritage_feed for update using (auth.uid() = user_id);

-- Realtime publication
alter publication supabase_realtime add table heritage_feed;
```

### Feed card widget (reusable)
```dart
class FeedCard extends StatelessWidget {
  final FeedItem item;
  const FeedCard({required this.item});

  // Renders: avatar | name | time | type badge | content | image | site link | like button
}
```

### Integration points
1. **Scanner screen** — after saving a visit, show "Share to Feed" bottom sheet.
2. **Damage report** — on submit success, "Post update to community?".
3. **Contribute screen** — after archive submission, "Share your contribution?".
4. **Quests screen** — on completion, "Tell everyone you earned this badge!".
5. **Bottom nav** — add Feed as index 1 (Home → Feed → Explore → Scanner → Archive → Profile).

### Hackathon demo script
1. Log in as two demo users (pre-created in Supabase).
2. User A posts a journal photo from Sigiriya → appears instantly on User B's feed (Realtime).
3. User B taps the site link → opens Explore screen centered on Sigiriya.
4. Say: *"Every photo, report, and story strengthens the collective memory of Sri Lanka's heritage."*

### Constraints & mitigations
| Risk | Mitigation |
|------|------------|
| Spam / low-quality posts | Type-specific required fields; keyword blocklist; admin queue |
| Image storage cost | Reuse existing bucket; compress client-side (already 88% quality) |
| No comments v1 | Keep v1 minimal — likes only. Comments = v2 with separate `feed_comments` table |

---

## 4. Photojournal Export (PDF / Ebook)

### Why
- The **Scanner/Journal** (`scanner_screen.dart`) already stores: photos, GPS, timestamps, notes, titles.
- Travellers want a **keepsake** — a printable PDF or shareable ebook of their heritage journey.
- Zero backend: pure client-side generation.

### What it does
- In **Journal/Scanner screen** (or Profile → "My Journal"), new button: **"Export Journey"**.
- Options dialog:
  - Date range (all / last 30 days / custom)
  - Include: photos, notes, map thumbnails, site descriptions
  - Format: **PDF** (print-ready) or **EPUB** (ebook reader)
- Output saved to `Downloads/HeritageLK_Journey_YYYY-MM-DD.pdf` → system share sheet.

### Tech plan
| Piece | Choice | Rationale |
|-------|--------|-----------|
| PDF engine | `pdf: ^3.11.0` + `printing: ^5.13.0` | Pure Dart, works offline, supports images/fonts |
| EPUB (optional) | `epub: ^3.0.0` | If time permits; PDF is MVP |
| Fonts | `google_fonts` (already in pubspec) for Playfair/Plus Jakarta | Brand consistency |
| Map thumbnails | `flutter_map` static image export or `google_static_maps` | Show visit location per entry |

**New dependencies:**
```yaml
pdf: ^3.11.0
printing: ^5.13.0
path_provider: ^2.1.2   # already in pubspec
permission_handler: ^11.3.0  # for storage permission on Android 13+
```

### PDF structure (per visit entry)
```
┌─────────────────────────────────────┐
│  HERITAGE LK — MY JOURNEY           │  ← Cover page: user name, date range, tier
│  [User Avatar]  Sanul Randisa       │
│  12 sites • 47 photos • 1,250 pts   │
├─────────────────────────────────────┤
│  SIGIRIYA ROCK FORTRESS             │  ← Entry header: site name + date + GPS
│  2026-07-15  06:42  7.957°N 80.760°E│
│  [Photo full-width]                 │
│  "Climbed at sunrise. The frescoes  │  ← User notes
│   are breathtaking..."              │
│  [Mini map thumbnail]               │  ← 200×200 map with pin
│  AI Insight: "Built by King         │  ← Optional: Shingo AI summary
│   Kashyapa in 477 AD..."            │
├─────────────────────────────────────┤
│  GALLE DUTCH FORT                   │  ← Next entry...
│  ...
└─────────────────────────────────────┘
```

### Integration points
1. **Scanner screen** — add `IconButton(Icons.picture_as_pdf)` in app bar.
2. **Profile screen** — "Export My Journey" list tile.
3. **Passport screen** (if built) — "Create Journey Book" button.

### Hackathon demo script
1. Open Scanner → Journal has 3–4 pre-seeded visits (Sigiriya, Galle, Nine Arches, Temple of Tooth).
2. Tap "Export Journey" → choose "All time" → "Generate PDF".
3. PDF opens in system viewer → scroll through beautiful pages.
4. Tap Share → send to WhatsApp/Email.
5. Say: *"Works offline. No server. Your heritage story, yours forever."*

### Constraints & mitigations
| Risk | Mitigation |
|------|------------|
| Large PDFs (many photos) | Downsample images to 1200 px max; show file size estimate before generation |
| Android 13+ storage permission | Use `permission_handler` + `MediaStore` API; fallback to app-specific `Downloads/` |
| Font licensing | `google_fonts` bundles OFL fonts — safe for embedding |

---

## Implementation Priority (Hackathon Timeline)

| Day | Focus | Deliverable |
|-----|-------|-------------|
| **Day 1** | Audio Guide + Passport (core logic) | TTS plays for 1 site; Passport grid shows 6 pre-seeded stamps |
| **Day 2** | Feed (DB + Realtime) + UI | Two demo users post → live cross-device feed |
| **Day 3** | Photojournal Export + Polish | PDF generates from 4 journal entries; share sheet works |
| **Day 4** | Integration & Demo Recording | All 4 features accessible from bottom nav; record 90-sec demo video |

---

## Shared Design Tokens (Reuse Existing)

| Token | Value | Used in |
|-------|-------|---------|
| `HeritageColors.cream` | `0xFFFEFAE0` | Text, icons |
| `HeritageColors.orange` | `0xFFF4A261` | Primary actions, accents |
| `HeritageColors.brown` | `0xFF342116` | Card backgrounds |
| `HeritageColors.background` | `0xFF100E0A` | Scaffold bg |
| Font: `Playfair Display` | Headlines, serif | Passport cover, PDF headers |
| Font: `Plus Jakarta Sans` | UI, body | Buttons, cards, PDF body |

All four features use **only these tokens** — zero new design debt.

---

## Appendix: Quick-start Commands

```bash
# Add new deps (run once)
flutter pub add flutter_tts screenshot share_plus lottie pdf printing permission_handler

# Generate PDF fonts (if using custom TTF)
# Place .ttf files in assets/fonts/ and declare in pubspec.yaml
```

---

*End of document. Each feature is independently shippable — pick any subset for the hackathon.*