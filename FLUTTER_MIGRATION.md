# HeritageLK Flutter Migration Map

This document summarizes what exists in the older app under `old/` and what needs to be rebuilt in Flutter.

## What The Old App Is

The current codebase is a React + Tailwind + Supabase app with:

- Auth screens for sign up and login
- A main home dashboard
- Heritage archive browsing and archive detail pages
- An AI archive generator flow
- A Shingo AI chat experience
- A map-based explore screen
- A camera-based scanner screen
- Quests and leaderboard screens
- Damage reporting and admin review screens
- Profile and settings screens
- A Tauri mobile/desktop shell in `src-tauri/`
- Server-side AI and Supabase helpers in `server/`

## Main User Flows To Rebuild

1. Authentication
- Sign up
- Login
- Session restore
- Auth callback handling

2. Home dashboard
- Welcome header
- User score, rank, and places visited
- Quick actions for report damage, scanner, map, archive, quests, and Shingo AI
- Nearby heritage cards
- Admin-only trigger action

3. Archive
- Browse archive list
- Search and category filtering
- Featured latest archive
- Open archive detail page
- Contribute new archive
- AI-generate archive from a topic

4. Shingo AI
- Streaming chat UI
- Message history
- Markdown rendering

5. Explore
- Interactive map with site markers
- Searchable heritage site list
- AI site details panel
- Weather summary
- Open/close and ticket price info

6. Scanner
- Camera preview
- Place search input
- Mock scan result panel
- 3D reconstruct mode UI

7. Quests
- Quest list
- Leaderboard
- Quest completion flow
- GPS check step
- Quiz step
- Points and completion state

8. Profile and settings
- User profile summary
- Points, rank, level, and completed quests
- Settings menu
- Sign out

9. Damage reporting
- Damage report form
- Damage type picker
- Photo/evidence UI
- Admin report list and status updates

## Routes In The Old App

These are the page routes currently wired in `client/App.tsx`:

- `/`
- `/auth/callback`
- `/login`
- `/signup`
- `/home`
- `/explore`
- `/quests`
- `/scanner`
- `/archive`
- `/archive/upload`
- `/archive/shingo`
- `/archive/admin/generate`
- `/archive/:id`
- `/report-damage`
- `/report-admin`
- `/profile`
- `/settings`

## Screens That Are Clearly Implemented

- `Index.tsx` sign up screen
- `Login.tsx` sign in screen
- `Home.tsx` dashboard
- `Archive.tsx` archive browser
- `ArchiveDetail.tsx` archive detail and generator
- `ContributeArchive.tsx` archive contribution form
- `ShingoAi.tsx` AI chat
- `Explore.tsx` map and site details
- `Quests.tsx` quests and leaderboard
- `Scanner.tsx` camera scanner UI
- `Profile.tsx` user profile
- `Settings.tsx` settings menu
- `ReportDamage.tsx` damage report form
- `ReportAdmin.tsx` report moderation screen
- `MainHome.tsx` simple landing screen

## Backend Routes To Recreate Or Replace

The Express server exposes:

- `GET /api/ping`
- `GET /api/site-details`
- `POST /api/generate-archive`
- `POST /api/shingo-chat`
- `POST /api/cron/generate-daily`
- `GET /api/demo`

## Server Responsibilities Today

The server currently handles:

- Streaming AI chat responses
- Streaming archive generation
- AI site details generation
- Daily archive generation with cron
- Private provider key lookup

For a Flutter rewrite, these responsibilities can stay server-side unless you intentionally move them to Supabase Edge Functions or another backend.

## Supabase Tables And Data Concepts

The app currently expects these concepts:

- `profiles`
- `archives`
- `quests`
- `user_quests`
- `damage_reports`
- `private.api_keys`

Likely fields used in the app:

- `profiles.id`
- `profiles.full_name`
- `profiles.city`
- `profiles.points`
- `archives.id`
- `archives.title`
- `archives.subtitle`
- `archives.location`
- `archives.category`
- `archives.content`
- `archives.intro`
- `archives.image`
- `archives.images`
- `archives.user_id`
- `archives.is_public`
- `quests.id`
- `quests.icon`
- `quests.title`
- `quests.description`
- `quests.points`
- `user_quests.user_id`
- `user_quests.quest_id`
- `damage_reports.location`
- `damage_reports.damage_type`
- `damage_reports.details`
- `damage_reports.status`
- `damage_reports.user_id`

## Environment Variables

These are the important config values from `.env.example`:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `NVIDIA_API_KEY`

In Flutter, these should become app config values and server-only secrets, not hardcoded values.

## Flutter Packages You Will Probably Need

Suggested Flutter equivalents:

- `supabase_flutter` for auth and database
- `go_router` for navigation
- `flutter_riverpod` or `provider` for app state
- `flutter_markdown` for Shingo AI and archive content
- `geolocator` for GPS
- `camera` or `image_picker` for scanner/report uploads
- `flutter_map` or `google_maps_flutter` for the explore map
- `http` or `dio` for backend requests
- `intl` for dates and formatting
- `cached_network_image` for image loading
- `flutter_svg` for logo and icons

## Recommended Flutter Screen Structure

Suggested pages:

- `Splash / Auth gate`
- `LoginPage`
- `SignUpPage`
- `HomePage`
- `ArchiveListPage`
- `ArchiveDetailPage`
- `ArchiveCreatePage`
- `ShingoChatPage`
- `ExploreMapPage`
- `ScannerPage`
- `QuestsPage`
- `ProfilePage`
- `SettingsPage`
- `ReportDamagePage`
- `ReportAdminPage`
- `NotFoundPage`

## Important Notes For The Rewrite

- The current UI is heavily custom styled with dark tones, gold/orange accents, and rounded cards.
- Several screens depend on Supabase auth state and profile data.
- The AI chat and archive generation flows are streamed, so Flutter should handle partial text updates instead of waiting for one final response.
- The map screen depends on live web map tiles and location data.
- The scanner screen currently uses camera access and simulated analysis, so Flutter should separate the camera preview from the fake scanning logic.
- Some settings links point to screens that are not actually implemented yet, so the Flutter rewrite should decide whether to create them or remove them.

## Suggested Build Order

1. App shell, theme, routing, and auth
2. Home, profile, and bottom navigation
3. Archive list, detail, and contribution flow
4. Shingo AI chat
5. Explore map and site detail panel
6. Quests and leaderboard
7. Scanner
8. Damage report and admin review
9. Settings and remaining utility screens
10. Backend migration or backend adapter layer

## Fastest Way To Start

If you want the rewrite to move quickly, the next practical step is to create a Flutter app with:

- a shared dark theme
- Supabase auth
- bottom navigation
- placeholder pages for every route above
- one shared repository/service layer for Supabase and API calls

Then we can replace each placeholder screen with the real UI one by one.
