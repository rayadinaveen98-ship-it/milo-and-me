# Roadmap and milestone gates

Current source: **0.1.0+1**. This is not yet a verified Android release.

| Milestone | Scope | Status |
| --- | --- | --- |
| 0 — Foundation | Brand, modules, engines, local schema, content definitions | Source implemented; Flutter verification pending |
| 1 — Vertical slice | Welcome/setup → pet home → drawing/puzzle/story → memory/reward | Source implemented; installed-device acceptance pending |
| Repository / CI bootstrap | Preserve original commits, public GitHub main, analysis/tests, debug APK artifact | Source/history published at `79ff254`; CI/APK gate running |
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

After that build gate, verify the APK on a device. Do not substitute offline structural checks for Flutter analysis, tests or runtime evidence. Record CI run, commit and artifact links here once they actually exist.
