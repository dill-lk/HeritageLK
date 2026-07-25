<div align="center">
<img width="1200" height="475" alt="GHBanner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />
</div>

# Run and deploy your AI Studio app

This contains everything you need to run your app locally.

View your app in AI Studio: https://ai.studio/apps/efe95422-916a-4f3c-9137-34d15a0827cb

## Run Locally

**Prerequisites:** Node.js

1. Install dependencies:
   (This project uses pnpm via Corepack.)
   `corepack enable`
   `corepack pnpm install`
2. Configure Supabase env values in `.env`:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY` (server only, never expose to client/Tauri)
   - `NVIDIA_API_KEY` (optional server-side fallback for Shingo/Archive generation)
3. Apply SQL in `supabase/sql/provider_api_keys.sql` to create the private key store table.
4. Insert provider keys (e.g. `gemini`, `nvidia`) into `private.api_keys` (see commented SQL insert examples in `supabase/sql/provider_api_keys.sql`).
5. Run the app:
   `corepack pnpm dev`
