# HeritageLK Flutter Rewrite Todo

Legend: `[x]` complete, `[~]` started/partial, `[ ]` not started.

## 1. Project Foundation

- [x] Read the old React/Tauri project and record the migration scope.
- [x] Create Flutter project files: `pubspec.yaml` and `analysis_options.yaml`.
- [x] Create Flutter entry point in `lib/main.dart`.
- [x] Create shared HeritageLK color tokens.
- [x] Create shared dark theme and typography setup.
- [x] Add typed archive and damage-report models.
- [x] Add environment-based Flutter configuration.
- [x] Add API client boundaries for the old server routes.
- [x] Add a Supabase archive repository boundary.
- [ ] Install Flutter SDK locally.
- [ ] Run `flutter pub get`.
- [ ] Run `flutter analyze` and fix all Dart errors.
- [ ] Run the app on Android, iOS, Windows, or web.
- [ ] Compare screenshots against the old app at mobile and desktop widths.

## 2. Exact Visual System

- [x] Preserve background `#100E0A`.
- [x] Preserve orange `#F4A261`.
- [x] Preserve brown `#8B5E3C`.
- [x] Preserve cream `#FEFAE0`.
- [x] Preserve green and gold accent values used by the old dashboard.
- [x] Preserve main button heights and rounded-rectangle shapes.
- [x] Preserve floating navigation height and radius.
- [ ] Port exact SVG icons. Current Flutter version uses matching Material icon equivalents in several places.
- [ ] Port exact image assets and remote image fallbacks.
- [ ] Verify every font weight, letter spacing, line height, and responsive breakpoint by screenshot.

## 3. Authentication Screens

- [x] Main landing screen with `HeritageLK`, tagline, Sign In, and Sign Up.
- [x] Sign-in screen layout and original copy.
- [x] Sign-up screen layout and original copy.
- [x] Password visibility controls.
- [x] Language selector visual state on sign-in.
- [x] Connect sign-in to Supabase password authentication.
- [x] Connect sign-up to Supabase account creation.
- [x] Add full name metadata/profile creation during sign-up.
- [ ] Add Google authentication.
- [ ] Add Apple authentication.
- [ ] Add forgot-password flow.
- [ ] Handle `/auth/callback` with real Supabase session exchange.
- [x] Add loading, validation, and error states matching the old app.

## 4. Main Navigation

- [x] Home destination.
- [x] Explore destination route.
- [x] Camera destination route.
- [x] Quests destination route.
- [x] Archive destination.
- [x] Shingo AI destination.
- [x] Profile route.
- [x] Settings route.
- [x] Report Damage route.
- [x] Floating bottom navigation visual shell.
- [ ] Match the old custom SVG navigation icons exactly.
- [ ] Add active-route state for nested archive and settings routes.

## 5. Home Dashboard

- [x] Header with avatar, Explorer label, greeting, and profile action.
- [x] Protect / Discover / Celebrate hero copy.
- [x] Places Visited, Points, and Rank stat pills.
- [x] Community damage alert card.
- [x] Report Damages action card.
- [x] Discover with Shingo action card.
- [x] Browse the Archive action card.
- [x] Load points from `profiles`.
- [x] Load rank from `profiles`.
- [x] Load visited places from `user_quests`.
- [ ] Connect daily archive generation trigger.
- [ ] Add real profile avatar and fallback behavior.

## 6. Explore

- [x] Explore screen UI with search, map-style panel, and heritage site list.
- [ ] Add interactive Leaflet/Google map equivalent.
- [ ] Add all 23 original heritage sites and coordinates.
- [x] Add search field and category filters.
- [x] Add selected marker state.
- [x] Add site detail bottom sheet.
- [x] Connect `/api/site-details`.
- [ ] Connect weather data from Open-Meteo.
- [ ] Add ticket price, best visit time, status, and AI overview.
- [ ] Add reset map and current-location actions.

## 7. Scanner

- [x] Camera screen UI with scan input and result panel.
- [ ] Add real camera preview.
- [x] Add scan/search input matching `Enter place to scan...`.
- [ ] Add original scan tabs and controls.
- [x] Add scan result panel with confidence, era, material, and description.
- [ ] Add camera permissions and denied state.
- [ ] Connect real image/site recognition service if required.

## 8. Quests

- [x] Quests screen UI with quest cards and leaderboard.
- [x] Port quest list and original quest copy.
- [x] Port leaderboard.
- [ ] Port quest completion modal.
- [ ] Add GPS verification.
- [x] Add quest completion writes to `user_quests`.
- [x] Add points update through the Supabase quest-completion trigger.
- [x] Add completed, locked, and active quest states.

## 9. Archive

- [x] Archive header and back action.
- [x] Archive search field.
- [x] All Records, Artifacts, Oral History, and Ancient Sites tabs.
- [x] Newly Discovered featured record layout.
- [x] Archive list card layout.
- [x] Empty/search state foundation.
- [x] Static sample archive records.
- [x] Load records from `archives`.
- [x] Add exact remote image behavior and failure fallback.
- [x] Add full archive detail screen UI.
- [ ] Add Markdown rendering for archive content.
- [ ] Add bookmark/save behavior.
- [x] Add AI archive generation screen.
- [x] Connect `/api/generate-archive` through the Flutter API client.
- [x] Save generated archive to Supabase.
- [x] Add contribution upload screen UI.
- [x] Add contribution upload screen backend.
- [ ] Add media uploads and 50MB validation.
- [x] Save contributions to `archives`.

## 10. Shingo AI

- [x] Shingo header and chat layout.
- [x] Original greeting text.
- [x] User and assistant message bubbles.
- [x] `Ask Shingo...` input.
- [x] Local send interaction and response placeholder.
- [x] Connect `/api/shingo-chat` through the Flutter API client.
- [ ] Support streamed assistant responses.
- [ ] Preserve Markdown and GitHub-flavored Markdown rendering.
- [ ] Add connection error and retry states.

## 11. Damage Reporting

- [x] Report Damage header.
- [x] Community Protection and `+100 Points` banner.
- [x] Verified Galle Fort location card.
- [x] Damage type dropdown.
- [x] Visual Evidence upload area.
- [x] Details field and submit button.
- [x] Local submit navigation.
- [ ] Add camera/gallery picker.
- [x] Save reports to `damage_reports` through the Flutter repository.
- [x] Guard optional `increment_points` RPC through the Flutter repository.
- [ ] Add success toast with exact old copy.
- [x] Add report admin list and status update UI flow.

## 12. Profile and Settings

- [x] Full profile route.
- [x] Settings screen UI.
- [x] Port profile avatar, level, progress, points, rank, and completed quests.
- [x] Load profile data from `profiles`.
- [x] Load completed quests from `user_quests`.
- [x] Add logout.
- [x] Port Personal Information screen UI.
- [x] Port Security screen UI.
- [x] Port Notifications screen UI.
- [x] Port Privacy & Data screen UI.
- [x] Port Help & Support screen UI.
- [ ] Add all settings toggles and persistence.

## 13. Backend and Supabase

- [x] Inspect and align with the real HeritageLK Supabase schema.
- [x] Configure `SUPABASE_URL` and anon key through a safe Flutter config method.
- [x] Add typed models for profiles, archives, quests, user quests, and damage reports.
- [x] Add repositories/services for profiles, archives, quests, user quests, and damage reports.
- [ ] Port auth session listener and protected-route behavior.
- [ ] Keep provider API keys server-only.
- [ ] Keep NVIDIA/Gemini calls behind the existing server routes.
- [x] Add API base URL configuration for mobile and desktop.
- [x] Inspect RLS policies for every user-facing operation.
- [x] Inspect admin-only operation policies.

## 14. Quality and Release

- [ ] Add widget tests for launch, login, signup, home, archive, and report screens.
- [ ] Add navigation tests for every old route.
- [ ] Add Supabase mock tests.
- [ ] Add API stream parsing tests for Shingo and archive generation.
- [ ] Add Android permissions for camera and location.
- [ ] Add iOS permissions for camera and location.
- [ ] Add app icon and splash screen from the old assets.
- [ ] Add responsive desktop layout matching the old max widths.
- [ ] Build release APK/AAB and measure size.
- [ ] Perform final pixel comparison against the old app.
- [ ] Remove all placeholder screens.
- [x] Document setup and production environment variables.
