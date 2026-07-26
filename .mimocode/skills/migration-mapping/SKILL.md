---
name: migration-mapping
description: "Read a legacy codebase, create a migration mapping document, and produce a structured todo list for rewriting it in a new framework. Use when migrating an app from one tech stack to another (e.g., React→Flutter, Vue→Next.js, jQuery→React)."
---

# Migration Mapping

Systematically read a legacy codebase, produce a migration mapping document, and generate a structured todo list for the rewrite.

## When to use

- User says "migrate", "rewrite", "port", or "rebuild" in a new framework
- User points at an `old/` or `legacy/` directory and asks to plan the new version
- User wants a structured plan before starting a rewrite

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| Legacy source directory | Yes | Path to the old app (e.g., `./old/client/`) |
| Target framework | Yes | The framework/language for the rewrite (e.g., Flutter, Next.js) |
| Output path | No | Where to write the mapping doc and todo (default: project root) |

## Procedure

### Phase 1 — Discover the old app

1. **List the directory tree** — `read` the legacy root to see folders and key config files (`package.json`, `pubspec.yaml`, `tsconfig.json`, etc.)
2. **Read config files** — Read `package.json` (dependencies, scripts), `tsconfig.json`, framework config, and routing config to understand the stack.
3. **Read all screen/page/component files** — Use `glob` to find all source files (`**/*.tsx`, `**/*.ts`, `**/*.dart`, etc.), then `read` every one. Do not skip files. Record:
   - File path
   - What it renders (screen, component, utility, hook, model)
   - Key data it fetches or state it manages
   - External dependencies (API calls, auth, third-party libs)
4. **Read server/backend files** — If present (`server/`, `api/`, `routes/`), read all backend endpoints. Record the route, method, and what it does.
5. **Read data layer** — Read database schemas, Supabase/Firebase config, shared types/models.

### Phase 2 — Map features

6. **Group screens by user flow** — Cluster related screens into flows (e.g., "Authentication flow" = login + signup + callback + forgot-password).
7. **Identify data dependencies** — For each flow, note which tables/APIs/state it reads from and writes to.
8. **Identify platform-specific concerns** — Camera, GPS, push notifications, file uploads, OAuth callbacks, deep links.
9. **Note UI patterns** — Custom components that need porting, shared themes, animations, responsive breakpoints.

### Phase 3 — Write the migration document

10. **Create `<FRAMEWORK>_MIGRATION.md`** with these sections:
    - **What The Old App Is** — Stack summary and feature inventory
    - **Main User Flows To Rebuild** — Numbered list grouped by flow
    - **Routes In The Old App** — All page routes
    - **Screens That Are Clearly Implemented** — File → feature mapping
    - **Backend Routes To Recreate** — API endpoints
    - **Server Responsibilities** — What stays server-side vs moves client-side
    - **Database Tables And Data Concepts** — Tables, fields, and relationships
    - **Environment Variables** — All config values and their Flutter/client equivalents
    - **Suggested Packages** — Framework-specific package recommendations
    - **Recommended Screen Structure** — Target file/class names
    - **Important Notes For The Rewrite** — Gotchas, streaming, auth state, etc.
    - **Suggested Build Order** — Priority-ordered phases

### Phase 4 — Write the todo list

11. **Create `<FRAMEWORK>_TODO.md`** with checklist items organized by phase:
    - Project Foundation (setup, theme, routing, models)
    - Visual System (colors, typography, spacing)
    - Each user flow as a section with specific subtasks
    - Backend & data layer integration
    - Quality & release (tests, permissions, build)
    - Use `[x]` for complete, `[~]` for started, `[ ]` for not started

### Phase 5 — Verify

12. **Cross-reference** — Grep the old codebase for any files, routes, or features not yet covered in the mapping doc.
13. **Confirm completeness** — Ensure every old route has a corresponding target screen, every API endpoint is documented, and every table/field is accounted for.

## Stopping condition

Done when both the migration document and todo list are written, cross-referenced against the old codebase, and confirmed complete by the user.

## Tips

- **Read every file.** Do not estimate or skip. The mapping is only as accurate as the reads.
- **Use actor subagents** for parallel reads when the codebase is large (e.g., spawn one actor per directory).
- **Record the actual source code patterns** (auth state, data fetching, error handling) so the rewrite doesn't miss subtle behavior.
- **Preserve the user's build order** if they specify one; otherwise use the suggested order from the migration doc.
