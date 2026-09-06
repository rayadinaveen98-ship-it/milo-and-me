# Roadmap and milestone gates

Current version: **0.1.0+1**, CI-verified Android debug playtest. Installed-device acceptance and store release remain pending.

| Milestone | Scope | Status |
| --- | --- | --- |
| 0 — Foundation | Brand, modules, engines, local schema, content definitions | Implemented; analysis/tests pass |
| 1 — Vertical slice | Welcome/setup → pet home → drawing/puzzle/story → memory/reward | Source implemented; installed-device acceptance pending |
| Repository / CI bootstrap | Preserve original commits, public GitHub main, analysis/tests, debug APK artifact | Complete: original history preserved; CI green and debug APK uploaded |
| 2 — Pet core | Richer animation, memory, care, wardrobe and progression | Baseline source implemented; polish/validation pending |
| 3 — Activity engines | Harden drawing, varied puzzle interaction, story playback | Baseline source implemented; hardening pending |
| 4 — Curated content | About 24 drawings, 50–60 puzzles, 10–12 stories, recorded voice | Starter content: 8 / 15 / 3; expansion pending |
| 5 — Parent/backend | Auth, verified consent, entitlements, downloads, optional backup | Adapter/schema source only; hosted implementation pending |
| 6 — Hardening | Normalized data/migrations, offline failures, accessibility, performance, playtests | Pending |
| 7 — Android release | Signing, versioning, store materials, release APK/AAB | Pending |
| 8 — iOS | Platform integration, purchases, iPhone/iPad, signing | After Android acceptance |

## Immediate definition of done

1. Existing Git history and audited complete source reach the owner-authorized public GitHub repository.
2. GitHub Actions resolves pinned direct dependencies and produces the dependency lockfile. No Dart code generation is required by the current explicit-SQL Drift implementation.
3. `flutter analyze`, all Flutter tests and Android APK build pass for the same source commit.
4. The installable debug APK is retained as a GitHub Actions artifact, with its commit identity and checksum.
5. Inspect failures, fix and push, then rerun until green or a genuine external blocker is documented.

First verified build: commit `fc7d2fabfe3f8f955c8c2e2f1a54cfb97456d973`, [green CI](https://github.com/rayadinaveen98-ship-it/milo-and-me/actions/runs/34037468340), [debug APK artifact](https://github.com/rayadinaveen98-ship-it/milo-and-me/actions/runs/34037468340/artifacts/9990702706) (2026-09-06). Analysis, all 28 Flutter tests, 19 offline tests and APK generation passed. The artifact contains `app-debug.apk` and a SHA-256/commit manifest; retention is 30 days. Newer successful runs produce their own matching artifacts.

Next, verify the APK on a device. Do not substitute offline structural checks for Flutter analysis, tests or runtime evidence.

## Approved continuation

The execution contract in `EXECUTION_V02_V07.md` supersedes the earlier milestone numbering: 0.2 companion; 0.3 core engines/content; 0.4 world areas; 0.5 cooking/roleplay; 0.6 science/discovery; 0.7 parent/backend/packs/premium. Proceed sequentially after each green CI/APK gate. Current work: 0.2 implemented, CI pending. User reports the installed 0.1 baseline has no material issues.
