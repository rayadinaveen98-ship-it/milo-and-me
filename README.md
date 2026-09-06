# Milo & Me — 0.1.0 Android playtest

Canonical source: **[rayadinaveen98-ship-it/milo-and-me](https://github.com/rayadinaveen98-ship-it/milo-and-me)**. Stable branch: `main`. GitHub Actions is the authoritative Flutter/Android verification environment. Milestone completion requires pushed source, green CI and a generated APK artifact.

A Flutter / Flame companion app for shared creativity, curiosity and gentle play, targeting ages 5–8. Working brand: **Milo & Me**. Original pet: **Milo**.

**GitHub CI is green and the Android debug APK is available.** Flutter analysis and all 28 Flutter tests pass in GitHub Actions. The local environment has no Flutter/Android SDK; CI is the build authority. This is an early playtest slice, with device acceptance and full V1 scope still pending. See `docs/STATUS.md` for evidence and limitations.

Implemented source flows:

- Welcome → parent introduction and six-digit PIN → nickname → pet naming/colour → bonding → illustrated pet room.
- Tappable pet, feeding, bubbles, sleep/wake and five wardrobe looks with activity unlocks.
- Drawing Watch/Together/Create modes, normalized strokes, animated guides, colour, brush size, eraser, undo/redo, draft persistence, PNG thumbnails and saved room artwork.
- 8 drawing lessons, 15 puzzles across five categories and 3 original branching stories.
- Story resume, puzzle completion, memory scrapbook and contextual pet suggestions.
- Local SQLite persistence through Drift, atomic memory saves, serialized world changes and reset.
- Parent PIN gate with PBKDF2 and retry lockout, sound/music/reduced-motion controls, session limits and profile deletion.
- Validated content-pack download repository and an optional Supabase REST adapter. Neither is connected to a hosted catalogue in this edition.

## Build an APK

Requirements: Flutter **3.35.7**, Java 17, Android SDK/toolchain accepted and configured, Python 3, network access to official build dependencies.

Windows:

```powershell
.\tool\build.ps1
```

macOS/Linux:

```bash
./tool/build.sh
```

The bootstrap script obtains the official Gradle wrapper from the installed Flutter SDK without overwriting application source. The official wrapper and resolved `pubspec.lock` are committed; retain lockfile changes when intentionally updating dependencies. No Drift code generation is needed.

Output after a successful build: `build/app/outputs/flutter-apk/app-debug.apk`.

Every push to `main` runs the **Android playtest APK** workflow: dependency installation, content validation, Flutter analysis, all Flutter tests, debug APK build and artifact upload. It can also be started manually from the [Actions page](https://github.com/rayadinaveen98-ship-it/milo-and-me/actions/workflows/android.yml). Download the `milo-and-me-0.1.0-debug-apk-…` artifact from a successful run and extract `app-debug.apk`. The artifact includes a commit/checksum manifest and is retained for 30 days. Debug APKs are for supervised testing; production signing is separate.

The owner authorized the public repository. The original source and Git history were preserved; each meaningful milestone must be committed and pushed.

First verified build: commit `fc7d2fabfe3f8f955c8c2e2f1a54cfb97456d973`, [green CI](https://github.com/rayadinaveen98-ship-it/milo-and-me/actions/runs/34037468340), [debug APK artifact](https://github.com/rayadinaveen98-ship-it/milo-and-me/actions/runs/34037468340/artifacts/9990702706) (2026-09-06). Analysis, all 28 Flutter tests, 19 offline tests and APK generation passed. The artifact contains `app-debug.apk` and a SHA-256/commit manifest; retention is 30 days. Newer successful runs produce their own matching artifacts.

## Run the available offline checks

```bash
python3 tool/validate_content.py assets/content/meadow.json
python3 tool/test_offline.py
python3 tool/check_source.py
```

The final command checks delimiters and local imports only. It cannot establish Dart type correctness, package compatibility, successful compilation or visual quality.

## Project map

| Directory | Purpose |
| --- | --- |
| `lib/domain` | World, memories, drawing data, deterministic activity/content rules |
| `lib/data` | Drift SQLite, pack integrity, secure PIN, optional parent backend |
| `lib/core` | Brand, Riverpod controller, session handling, audio abstraction |
| `lib/features` | Onboarding, room, activities, parent controls, wardrobe, memories |
| `lib/ui` | Shape-rendered Flame pet and shared UI |
| `assets/content` | Original JSON starter pack |
| `assets/brand` | App icons and wordmark |
| `test` | Flutter engine, repository, controller, security and widget tests |
| `supabase/schema.sql` | Unapplied candidate cloud schema |
| `docs` | Architecture, content formats, release steps, precise limitations |

Read `docs/STATUS.md` before continuing. `docs/PRODUCT_BRIEF.md` preserves the supplied scope. Nothing in this milestone changes that long-term brief.

## Locked project documents

- `docs/PRODUCT_FOUNDATION.md`: philosophy, audience and V1 boundaries.
- `docs/ARCHITECTURE.md`: Flutter/Flame, Riverpod, navigation, persistence and service boundaries.
- `docs/ROADMAP.md`: milestones and evidence-based completion gates.
- `docs/PRIVACY_AND_CHILD_SAFETY.md`: privacy and parental authority rules.
- `docs/CONTENT_SYSTEM.md`: content schemas and pack activation.
