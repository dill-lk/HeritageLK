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
- [ ] Install Flutter SDK locally. **(Required: run `flutter --version` to verify)**
- [ ] Run `flutter pub get`. **(Run after SDK is installed)**
- [ ] Run `flutter analyze` and fix all Dart errors. **(Run after `pub get`)**
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
- [x] Add forgot-password flow.
- [x] Handle `/auth/callback` with real Supabase session exchange.
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
- [x] Floating bottom navigation visual shell with 6 tabs (Home, Explore, Camera, Quests, Archive, Shingo).
- [ ] Match the old custom SVG navigation icons exactly.
- [ ] Add active-route state for nested archive and settings routes.

## 5. Home Dashboard

- [x] Header with avatar, Explorer label, greeting, and profile action.
- [x] Protect / Discover / Celebrate hero copy.
- [x] Places Visited, Points, and Rank stat pills.
- [x] Community damage alert card.
- [x] Report Damages action card.
- [x] Scanner / Map / Archive grid layout matching old app.
- [x] Shingo AI banner card.
- [x] Quests banner card.
- [x] Nearby Heritage section with Galle Fort and Yatagala Temple cards.
- [x] Load points from `profiles`.
- [x] Load rank from `profiles`.
- [x] Load visited places from `user_quests`.
- [ ] Connect daily archive generation trigger.
- [ ] Add real profile avatar and fallback behavior.

## 6. Explore

- [x] Explore screen UI with search, map-style panel, and heritage site list.
- [x] Add all 30 original heritage sites with coordinates and AI overviews.
- [x] Add search field with suggestions dropdown.
- [x] Add category filter chips (All, History, Nature).
- [x] Add selected marker state with red highlight.
- [x] Add bottom info card with site name, UNESCO badge, Scan Site button.
- [x] Connect `/api/site-details`.
- [x] Connect weather data from Open-Meteo (temperature and wind speed).
- [x] Add ticket price, status, and AI overview in info card.
- [x] Add AI Quick Insights section with weather display.
- [ ] Add interactive Leaflet/Google map equivalent (currently uses custom painter).
- [ ] Add reset map and current-location actions.

## 7. Scanner

- [x] Camera screen UI with scan input and result panel.
- [x] Add scan/search input matching "Enter place to scan...".
- [x] Add Sites / Plants / Wildlife tab buttons.
- [x] Add 3D Reconstruct mode toggle.
- [x] Add scan result panel with confidence, era, material, and description.
- [ ] Add real camera preview.
- [ ] Add camera permissions and denied state.
- [ ] Connect real image/site recognition service if required.

## 8. Quests

- [x] Quests screen UI with Heritage Protector card, Top Users leaderboard, Available/Completed sections.
- [x] Port all 13 fallback quests with icons, descriptions, and point values.
- [x] Port leaderboard with name, city, and formatted score.
- [x] Port quest completion modal with intro, GPS checking, quiz, and completion states.
- [x] Heritage Protector card with points, rank, level, and progress bar.
- [x] Quest Start button triggers modal flow.
- [x] GPS verification step (with fallback for denied permissions).
- [x] Quiz step with correct answer validation.
- [x] Completed quests with Claimed badge and checkmark.
- [x] Add quest completion writes to `user_quests`.
- [x] Add points update through the Supabase quest-completion trigger.

## 9. Archive

- [x] Archive header with back, Shingo logo button, and search.
- [x] Archive search field.
- [x] All Records, Artifacts, Oral History, and Ancient Sites tabs with orange active state.
- [x] Newly Discovered featured record with pulsing dot and gradient overlay.
- [x] Archive list card layout with location pin, title, and content preview.
- [x] Floating orange "+" add button above bottom nav.
- [x] Empty/search state with BookOpen icon.
- [x] Shingo logo button navigates to AI chat.
- [x] Load records from `archives`.
- [x] Add exact remote image behavior and failure fallback.
- [x] Archive Detail: Immersive header image with gradient, back/bookmark buttons, subtitle badge, title, location.
- [x] Archive Detail: Content body with italic intro, section headings, image grid, "Did you know?" card.
- [x] Add AI archive generation screen.
- [x] Connect `/api/generate-archive` through the Flutter API client.
- [x] Save generated archive to Supabase.
- [x] Add contribution upload screen UI with title, category, description, media upload area, public toggle.
- [x] Add contribution upload screen backend.
- [x] Save contributions to `archives`.

## 10. Shingo AI

- [x] Shingo header with back, logo, sparkle icon, and title matching old app.
- [x] Original greeting text.
- [x] User and assistant message bubbles with correct border radius and colors.
- [x] `Ask Shingo...` input with gold send button.
- [x] Connect `/api/shingo-chat` through the Flutter API client.
- [x] Loading state with bouncing dots animation.
- [x] Auto-scroll to bottom on new messages.
- [x] Connection error and retry states.

## 11. Damage Reporting

- [x] Report Damage header with back and notification buttons.
- [x] Community Protection and +100 Points banner.
- [x] Verified Galle Fort location card with VERIFIED badge.
- [x] Damage type dropdown with warning icon.
- [x] Visual Evidence: ADD PHOTO button + two sample photos.
- [x] Details field with hint text matching old app.
- [x] Submit Report button with loading state.
- [x] Save reports to `damage_reports` through the Flutter repository.
- [x] Report Admin: Stats grid (TOTAL, PENDING, IN REVIEW, RESOLVED).
- [x] Report Admin: Filter chips for status.
- [x] Report Admin: Report cards with type, location, details, and Review/Resolve/Reject actions.
- [x] Add camera/gallery picker (image_picker package added).

## 12. Profile and Settings

- [x] Full profile route with back button.
- [x] Profile avatar with edit button overlay.
- [x] Name, Level, MASTER badge.
- [x] Progress bar with gradient from green to gold.
- [x] Stats row: Points, Places, Rank with icons.
- [x] Achievements section with horizontal scroll.
- [x] Recent Discoveries section with image cards.
- [x] Action links: Edit Profile, My Quests, Settings, Help & Support.
- [x] Logout button with red border.
- [x] Load profile data from `profiles`.
- [x] Load completed quests from `user_quests`.
- [x] Settings screen with header background image, user preview, and sections.
- [x] Settings menu items navigate to their detail screens.
- [x] Settings Detail: Personal Info, Security, Notifications, Privacy, Help screens with toggles and info fields.
- [x] Settings footer with "PRESERVE THE LEGACY" and version number.

## 13. Backend and Supabase

- [x] Inspect and align with the real HeritageLK Supabase schema.
- [x] Configure `SUPABASE_URL` and anon key through a safe Flutter config method.
- [x] Add typed models for profiles, archives, quests, user quests, and damage reports.
- [x] Add repositories/services for profiles, archives, quests, user quests, and damage reports.
- [x] Port auth session listener and protected-route behavior.
- [ ] Keep provider API keys server-only.
- [ ] Keep NVIDIA/Gemini calls behind the existing server routes.
- [x] Add API base URL configuration for mobile and desktop.
- [x] Inspect RLS policies for every user-facing operation.
- [x] Inspect admin-only operation policies.

## 14. Quality and Release

- [x] Add widget tests for launch, login, signup, home, archive, and report screens.
- [x] Add navigation tests for every old route.
- [x] Add Supabase mock tests.
- [x] Add API stream parsing tests for Shingo and archive generation.
- [x] Add Android permissions for camera and location.
- [x] Add iOS permissions for camera and location.
- [x] Add app icon and splash screen from the old assets.
- [x] Add responsive desktop layout matching the old max widths.
- [ ] Build release APK/AAB and measure size.
- [ ] Perform final pixel comparison against the old app.
- [x] Remove all placeholder screens.
- [x] Document setup and production environment variables.
