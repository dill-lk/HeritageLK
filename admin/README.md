# HeritageLK Damage Reports Admin Web App

A standalone, responsive web application for managing heritage damage reports in Sri Lanka. It connects independently to **Supabase** (`damage_reports` table) or operates in offline demo mode.

---

## 🌟 Key Features

- **Standalone Web App**: Fully independent HTML5/CSS3/JavaScript web client located in `/admin`.
- **Direct Supabase Integration**: Uses `@supabase/supabase-js` v2 to fetch, insert, update, and delete reports directly from the `damage_reports` table.
- **Offline & Demo Mode**: Pre-loaded with realistic Sri Lankan heritage site damage reports (Sigiriya, Galle Fort, Dambulla, Polonnaruwa) when offline or before API credentials are set up.
- **Status & Workflow Management**: Change status between `Pending`, `In Review`, `Resolved`, and `Rejected` with resolution notes.
- **Analytics & Visualization**: Interactive summary stats cards and Chart.js charts (Status distribution & Damage types breakdown).
- **Search & Filters**: Real-time multi-field search and status/type filter chips.
- **Data Export**: Export damage logs to **CSV** or **JSON** formats for official report submissions.
- **Mobile Optimized**: Responsive layout with both Table View and Touch Card Grid View.

---

## 🚀 How to Run & View

Since `/admin` is a standalone web application, you can serve it with any HTTP static file server or view it directly in any browser:

### Option 1: Using Python built-in HTTP server
```bash
cd admin
python -m http.server 8080
```
Then open `http://localhost:8080` in your web browser.

### Option 2: Using Node.js npx serve
```bash
npx serve admin
```

### Option 3: Direct File Opening
Open `admin/index.html` directly in Google Chrome, Microsoft Edge, or Firefox.

---

## 🔑 Supabase Database Table Schema

The web app expects the following Supabase `damage_reports` table schema:

| Column Name | Type | Description |
|---|---|---|
| `id` | text / uuid | Unique report ID |
| `location` | text | Site name & region |
| `damage_type` | text | e.g. Structural Crack, Vandalism, Erosion |
| `details` | text | Inspection description |
| `status` | text | `pending`, `in_review`, `resolved`, `rejected` |
| `created_at` | timestamp | Report submission timestamp |
| `photos` | jsonb / text | Image URLs |
| `notes` | text | Resolution or inspector notes |

---

## ⚙️ Configuration

Tap the **Settings ⚙️** icon in the header to enter your custom Supabase Project URL (`SUPABASE_URL`) and Anon Key (`SUPABASE_ANON_KEY`). Credentials are saved securely in browser `localStorage`.
