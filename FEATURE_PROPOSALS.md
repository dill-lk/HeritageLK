# HeritageLK — Proposed Feature Deep-Dive

> Audience: hackathon judges, technical reviewers, and future contributors.  
> Goal: explain the **why**, **what**, and **how** of four selected features in enough detail to build and demo quickly.

---

## 1. Heritage Audio Guides (`flutter_tts`)

### Why
- Visitors to Sri Lankan heritage sites often read long placards or miss context entirely.
- Audio delivery is low-bandwidth, inclusive (visually impaired, elderly, children), and memorable.
- Differentiates HeritageLK from generic map apps by adding a **curated local narrative layer**.

### What it does
- Each heritage site (from the existing `_allSites` list in `explore_screen.dart`) gets an audio narration button.
- Users tap **"Listen"** on a site card → the app reads aloud a 60–120 second script covering:
  - Historical significance
  - Key dates and figures
  - What to look for when visiting
  - A cultural tip or local legend
- Narrations are available in **English, Sinhala, and Tamil**.
- Users can download narrations for offline use while traveling to remote sites (e.g., Sigiriya, Mihintale).

### Technical approach
- **TTS engine**: `flutter_tts` (works on Android/iOS, supports Sinhala/Tamil via platform voices).
- **Script storage**: small JSON/Text files bundled with the app or fetched from Supabase Storage (`heritage-audio/scripts/{siteId}.txt`).
- **Caching**: save MP3 bytes (if using cloud TTS) or just pre-render scripts locally in `getApplicationDocumentsDirectory()`.
- **UI**: add a small speaker icon to every `_NearbyCard`, `_archiveTile`, and site detail card.
- **Playback controls**: mini bottom-sheet with play/pause, speed (0.8x–1.5x), and language selector.

### Data model (minimal)
```dart
class AudioGuide {
  final String siteId;
  final String languageCode; // 'en', 'si', 'ta'
  final String scriptText;
  final String? remoteAudioUrl; // optional pre-generated MP3
}
```

### Hackathon demo hook
- Record one high-quality Sinhala narration for **Sigiriya Rock Fortress** as the demo asset.
- Show the audio player UI and play it on-device during the pitch.
- Mention that scaling to 70+ sites only requires uploading script text files.

### Constraints & mitigations
- **No internet**: scripts are bundled or cached locally; TTS works offline.
- **Voice quality**: platform TTS is acceptable for a demo; mention that production can swap in ElevenLabs/AWS Polly for richer voices.
- **Storage**: script text is ~2KB per site; 70 sites ≈ 140KB — negligible.

---

## 2. Digital Heritage Passport (Local-First Gamification)

### Why
- The app already has points, ranks, and quests (`quests_screen.dart`).
- A **passport** gives users a visual, collectible representation of their journey — highly shareable and emotionally resonant.
- Offline-first is essential because many heritage sites have poor mobile coverage.

### What it does
- A dedicated **"My Passport"** tab inside the Profile screen.
- Displays a grid of **site stamps** (custom icons) that fill in as users:
  - Physically visit a site (GPS geofence trigger)
  - Scan a site via the Camera/Scanner screen
  - Complete a related quest
- Each stamp shows:
  - Site name
  - Visit date
  - Earning method (visited / scanned / quest)
- **Tiers**: Bronze (5 sites), Silver (15 sites), Gold (35 sites), Heritage Legend (all 70+).
- Users can share a **passport summary card** as an image (using `screenshot` + `share_plus`).

### Technical approach
- **Storage**: `shared_preferences` or a local JSON file (`passport.json`) — **no cloud database needed**.
- **Geofence trigger**: use `geolocator` distance check against site lat/lng when the app detects a location update (already implemented in `home_screen.dart`).
- **Stamp creation**: lightweight local object; no Supabase writes.
- **UI**: animated grid with `AnimatedContainer` + `Lottie` (optional) for stamp "press" effect.
- **Share**: `screenshot` package captures the passport widget; `share_plus` exports to Instagram/WhatsApp.

### Data model (local-only)
```dart
class PassportStamp {
  final String siteId;
  final String siteName;
  final DateTime visitedAt;
  final String method; // 'gps' | 'scan' | 'quest'
}

class Passport {
  final List<PassportStamp> stamps;
  int get bronzeCount => stamps.where((s) => s.method == 'gps').length;
  String get tier => ... // Bronze / Silver / Gold / Legend
}
```

### Hackathon demo hook
- Pre-seed 5–6 stamps in the demo build so judges see a populated passport immediately.
- Show the **share-card** generation flow (1-tap export to image).
- Emphasize **offline-first**: "All your heritage memories live on your device, forever."

### Constraints & mitigations
- **No heavy database**: passport is purely local JSON; zero backend cost.
- **GPS spoofing**: for demo purposes, accept manual "Add to Passport" buttons; in production, add a cooldown + distance threshold.
- **Sync optional**: if Supabase is available, optionally back up stamps to a `user_passport` table — but it's not required for the feature to work.

---

## 3. Heritage Feed (Community Social Layer)

### Why
- Heritage preservation is inherently communal. Users want to see what others discovered.
- A feed turns the app from a **tool** into a **community platform**.
- Drives daily active usage and creates user-generated content that enriches the archive.

### What it does
- A new **"Feed"** tab (between Home and Explore) showing a scrollable list of community posts.
- Post types:
  - **Photo journal entry** (from the Scanner/Camera screen) — user shares a visit photo with notes
  - **Damage report update** — "I reported damage at Galle Fort; here's the status change"
  - **Archive contribution** — "I added a story about traditional mask making"
  - **Quest completion** — "I just earned the Fort Guardian badge!"
- Each post shows:
  - Author avatar + name
  - Timestamp (e.g., "2 hours ago")
  - Content (photo, text, or both)
  - Linked heritage site (tap to open map/details)
  - Like ❤️ and comment count (light engagement, no full social graph needed)
- **Moderation**: basic keyword filter + admin review queue (reuse existing damage report admin pattern).

### Technical approach
- **New Supabase table**: `heritage_feed`
  ```sql
  create table heritage_feed (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users,
    type text, -- 'journal' | 'damage' | 'archive' | 'quest'
    site_id text,
    content text,
    image_url text,
    likes int default 0,
    created_at timestamp default now()
  );
  ```
- **Row Level Security**: users can insert their own posts; public read access.
- **Realtime**: subscribe to `INSERT` events on `heritage_feed` for live feed updates (Supabase Realtime).
- **Image storage**: reuse existing `heritage-media` bucket for uploaded photos.
- **Feed UI**: `ListView.builder` with a unified `_FeedCard` widget; pull-to-refresh.

### Data flow
1. User completes an action in the app (e.g., saves a journal photo).
2. App prompts: "Share this moment with the HeritageLK community?"
3. If yes → create a feed post linked to the site + user.
4. Post appears in everyone's Feed tab instantly via Realtime subscription.

### Hackathon demo hook
- Pre-seed 8–10 realistic posts with placeholder images (Unsplash) so the feed looks alive on first launch.
- Show a **live like animation** when tapping the heart icon.
- Mention scalability: "This is a read-heavy, append-only feed — perfect for Supabase Realtime + CDN images."

### Constraints & mitigations
- **No heavy moderation AI**: use a simple blocklist + admin flag button; judges will accept this for a demo.
- **Storage costs**: images are thumbnails (200–400px) using `image_picker` quality compression; CDN costs stay low.
- **Feed fatigue**: cap at 50 posts locally + infinite scroll with `LIMIT 20` queries.

---

## 4. Photojournal Export (`pdf` + `share_plus`)

### Why
- Users accumulate rich journal data (photos, GPS coordinates, notes, timestamps) in the Scanner screen.
- Exporting this into a **beautiful PDF** gives tangible value and a shareable artifact.
- Perfect for travelers, researchers, and school projects — extends the app's utility beyond the phone.

### What it does
- A **"Export Journal"** button in the Profile / Scanner screen.
- Generates a multi-page PDF containing:
  - **Cover page**: "My HeritageLK Journal" + user name + date range
  - **Table of Contents**: list of visited sites
  - **Visit pages**: one per journal entry, each with:
    - Full-bleed photo
    - Site name & GPS coordinates
    - Visit date & time
    - User notes
    - Small embedded map snippet (optional static image from `flutter_map` screenshot)
  - **Summary page**: total visits, countries/regions visited, top sites
- Output options:
  - Save to device Files app
  - Share via WhatsApp / Email / AirDrop
  - Print directly

### Technical approach
- **PDF generation**: `pdf` package (pub.dev) — renders Dart widgets to PDF natively.
- **Map snapshot**: optional; use `flutter_map` controller + `screenshot` package, or skip for speed.
- **Image handling**: resize images to 1200px width before embedding to keep PDF under 10MB.
- **Sharing**: `share_plus` with `XFile` from `path_provider`.
- **Styling**: use the same HeritageLK color palette (`HeritageColors`) and fonts (`Plus Jakarta Sans`, `Playfair Display`) for brand consistency.

### Implementation sketch
```dart
Future<void> _exportJournalPdf(List<_Visit> visits) async {
  final pdf = Document();
  pdf.addPage(MdpdfPage.build(
    cover: 'My HeritageLK Journal',
    pages: visits.map((visit) {
      return PageBuild(
        image: File(visit.imagePath),
        title: visit.title,
        subtitle: '${visit.latitude.toStringAsFixed(4)}°, ${visit.longitude.toStringAsFixed(4)}°',
        notes: visit.notes,
        date: DateFormat.yMMMd().add_jm().format(visit.timestamp),
      );
    }).toList(),
  ));
  final file = File('${(await getApplicationDocumentsDirectory()).path}/heritage_journal.pdf');
  await file.writeAsBytes(await pdf.save());
  await Share.shareXFiles([XFile(file.path)], text: 'My HeritageLK Journal');
}
```

### Hackathon demo hook
- Have 3–4 pre-seeded journal entries in the demo.
- Tap **Export** → show the generated PDF preview in a bottom sheet → share.
- Judges see a polished, branded document generated in real time — extremely impressive.

### Constraints & mitigations
- **Large images**: compress with `flutter_image_compress` before embedding.
- **Font licensing**: `Plus Jakarta Sans` and `Playfair Display` are open-source (OFL) — safe to bundle.
- **iOS sharing**: `share_plus` handles UIActivityViewController automatically.
- **No cloud dependency**: everything runs on-device; no uploads needed.

---

## Implementation Priority for Hackathon

| Feature | Effort | Impact | Recommended Order |
|---------|--------|--------|-------------------|
| Audio Guides | 1–2 days | High (emotional + inclusive) | **2nd** |
| Heritage Passport | 2–3 days | High (gamification hook) | **3rd** |
| Heritage Feed | 2–3 days | High (social virality) | **4th** |
| Photojournal Export | 1 day | Medium-High (tangible deliverable) | **1st** |

### Suggested 3-day sprint plan

**Day 1**
- Implement Photojournal Export (`pdf` package).
- Add Export button to Scanner screen.
- Test PDF generation with 5 sample visits.

**Day 2**
- Build Heritage Passport screen + local JSON storage.
- Add GPS-based stamping logic.
- Pre-seed 5 demo stamps.

**Day 3**
- Build Audio Guide player widget.
- Add Sinhala narration for Sigiriya as the demo audio.
- Polish UI animations and add share-card screenshot.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| TTS voices unavailable for Sinhala/Tamil on test devices | Bundle a pre-rendered MP3 for demo; mention cloud-TTS fallback in pitch |
| PDF generation crashes on large images | Compress images to max 1200px before embedding |
| Passport feels empty on first launch | Pre-seed 5–6 stamps in demo build |
| Feed looks ghost-town without real users | Seed 12+ realistic placeholder posts |

---

## Closing Note

These four features are chosen because they:
1. **Reuse existing data** (sites, visits, user profile)
2. **Avoid heavy backend costs** (local-first passport, optional cloud sync)
3. **Deliver visible demo value** (shareable PDF, audio playback, stamp collection)
4. **Align with the app's core mission**: protect, discover, and celebrate Sri Lankan heritage.

Build one, demo it well, and the judges will remember the experience.
