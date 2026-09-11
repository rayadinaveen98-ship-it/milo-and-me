# Milo & Me · 0.7.5

A child's virtual best friend for ages roughly 5–8. Milo and the child draw, solve puzzles, share stories, care, imagine, cook pretend recipes and discover together. Local-first; no child login, ads, public chat, behavioural analytics or runtime AI chat.

[Download verified APKs](https://github.com/rayadinaveen98-ship-it/milo-and-me/releases) · [Android CI](https://github.com/rayadinaveen98-ship-it/milo-and-me/actions/workflows/android.yml)

The approved activity engines and original Git history are preserved. v0.7.5 rebuilds the presentation with original illustrated rooms, sprout-eared Milo, visual costumes and props, and the interactive narrated **Milo and the Missing Moonlight** story. See [roadmap](docs/ROADMAP.md), [release notes](docs/RELEASE_NOTES.md) and [visual verification](docs/V075_VISUAL_REVIEW.md) for the release evidence and remaining device checks.

## Stack and structure

Flutter 3.35.7 / Dart, Flame for Milo, Riverpod, go_router, Drift/SQLite, secure storage, audioplayers and Flutter in-app purchase adapters.

- `lib/domain`: deterministic pet, memory, activity, access and content rules.
- `lib/core`: controller, services/configuration, audio and version.
- `lib/data`: SQLite migrations, verified packs, parent auth and purchase adapters.
- `lib/features`, `lib/ui`: approved child experience, parent controls and lazy previews.
- `assets/content`: 24 drawings, 55 puzzles, 13 stories, 5 recipes, 6 roleplays, 10 discoveries.
- `assets/art`, `assets/audio`: compressed original artwork and authored offline narration; provenance accompanies both.
- `supabase`: server API, schema, CLI-generated migration and ownership tests.
- `test`, `tool`: Flutter suites, portable server tests and offline content checks.

## Development and Android build

```sh
python3 tool/bootstrap_android.py
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Use Java 17 and the pinned Flutter version. Explicit SQL Drift requires no Dart code generation. On a fresh checkout, the bootstrap script obtains the official Android wrapper from Flutter without regenerating app source. CI retains the dependency lock, wrapper and CLI-generated migration, runs PostgreSQL ownership/server tests, content checks, analysis and all Flutter tests, then builds and publishes the APK plus a source/checksum manifest. GitHub Actions is authoritative because the editing environment has no Flutter/Android SDK.

Default builds are offline playtests with the full included library. Real parent services require public build configuration and server-only credentials; [activation guide](docs/BACKEND_ACTIVATION.md) lists exact steps. No live billing is simulated as a real purchase. Release signing must be configured externally; debug APKs are for supervised playtesting, and separately generated debug keys may prevent in-place upgrades.

## Product and technical contracts

[Product foundation](docs/PRODUCT_FOUNDATION.md) · [Architecture](docs/ARCHITECTURE.md) · [Content schemas](docs/CONTENT_SYSTEM.md) · [Privacy and child safety](docs/PRIVACY_AND_CHILD_SAFETY.md) · [Execution contract](docs/EXECUTION_V02_V07.md)

`main` in `rayadinaveen98-ship-it/milo-and-me` is authoritative. A milestone is complete only after pushed source, passing CI and a published APK. Keep credentials, signing files, private child information and build output out of Git.
