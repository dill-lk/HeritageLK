# HeritageLK Supabase Flutter Setup

Use Flutter `--dart-define` values instead of hardcoding credentials in source.

Project URL:

```text
https://emeqmaqmmaohkeecyvjq.supabase.co
```

Preferred publishable key type:

```text
sb_publishable_...
```

Run shape when Flutter is available:

```powershell
flutter run --dart-define=SUPABASE_URL=https://emeqmaqmmaohkeecyvjq.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_... --dart-define=API_BASE_URL=http://localhost:3000
```

The Flutter code currently reads:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `API_BASE_URL`

Supabase schema confirmed on July 25, 2026:

- `archives`
- `profiles`
- `quests`
- `user_quests`
- `heritage_sites`
- `qr_codes`
- `damage_reports`
- `admin_accounts`
- `user_ranks`

Important database details:

- `user_quests` uses `completed_at`, not `created_at`.
- `damage_reports.status` allows `pending`, `in_review`, `resolved`, and `rejected`.
- Quest point updates are handled by the database trigger `handle_quest_completion`; the Flutter app should not call an `increment_points` RPC for quests.
- The old server route `/api/site-details` expects the query parameter `name`.
