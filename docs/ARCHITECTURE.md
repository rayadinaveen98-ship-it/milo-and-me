# Architecture

The child’s relationship with the pet remains the centre: activity completions create memories, display creations in the home, unlock outfits and influence deterministic dialogue. There is no absence penalty, ad, chat, cloud LLM or child analytics.

Flutter screens read an injected Riverpod `AppController`. The controller owns domain transitions and serializes world writes. UI state is published after the SQLite transaction commits. Flame receives only pose, outfit, colour and reduced-motion state; it does not own persistence or unrelated activity rules.

`AppDatabase` uses Drift’s native SQLite executor and explicit SQL creation/migration hooks. Schema v1 has `world`, `drawing_drafts`, `session` and `packs`. Upgrade paths fail explicitly until a genuine next-version migration is supplied. No generated Drift file is missing.

`world` is currently a JSON aggregate with nickname, pet profile/state, appearance, inventory, progress, scene positions, local settings and memories. Drawings store normalized vector strokes and PNG thumbnails inside memory payloads. This choice is deliberately limited to the initial slice; it must be normalized for production scale. Session checkpoints and unfinished drawings are separate to reduce frequent world rewrites.

Content is authored as JSON and loaded through `ContentRepository`. Before remote installation, the repository verifies HTTPS, a maximum byte count, trusted expected SHA-256, pack identity/version, schema, branches and catalogue collisions. Only then does one transaction replace the stored pack. Network failure does not delete installed content.

Parent security uses platform secure storage for a random-salted PBKDF2-HMAC-SHA256 PIN hash and persisted retry lockout. Parent authorization is in memory and revoked when the app leaves the foreground. This is a parental gate, not a verified legal identity or cloud consent mechanism.

The optional parent backend interface supplies catalogue and entitlement reads. The Supabase implementation accepts an injected, refreshed parent access token. It never receives child data. It is not instantiated by the offline bootstrap. Server-side store verification, authentication, account deletion, verified consent and encrypted backup remain separate work.

The candidate cloud schema uses owner-scoped read policies and server-only writes. This follows Supabase’s requirement to combine row-level policies with explicit privileges; it still needs actual ownership tests before deployment. See [Supabase RLS documentation](https://supabase.com/docs/guides/database/postgres/row-level-security).

Sound is behind `AudioService`: quiet generated room audio, effects and an authored-narration replacement point. `SilentAudio` supports testing without platform plugins. No child voice is recorded and no online TTS is called.

Brand strings and colours live in `core/brand.dart`. The pet is drawn using production-reproducible primitives; a later Rive adapter can replace `PetView` while retaining its state contract. The first screen meets the pet quickly, then gives the grown-up local storage/PIN setup. Completed artwork appears on the wall, while the room’s easel, books, puzzle box, wardrobe and shelf are tappable destinations.

Navigation uses go_router with an onboarding redirect. Child routes are wrapped in a session-break overlay which preserves the underlying screen until navigation. Parent routes always render the PIN gate until authorized. The architecture follows Flutter’s documented declarative routing approach: [Flutter navigation](https://docs.flutter.dev/ui/navigation).

## Repository and build authority

`rayadinaveen98-ship-it/milo-and-me` on `main` is authoritative. GitHub Actions installs Flutter/Android dependencies, bootstraps the official Gradle wrapper, analyzes, tests and builds the APK. The explicit-SQL Drift implementation requires no Dart code generation. Preserve existing commits; push each meaningful milestone and record actual CI/artifact evidence. Offline local checks are supplementary only.
