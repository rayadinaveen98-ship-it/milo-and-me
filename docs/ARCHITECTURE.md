# Technical architecture

Flutter screens consume a Riverpod `AppController`; go_router preserves onboarding and child session guards. Flame renders bounded deterministic Milo poses. Domain engines own pet reactions, memory, puzzles, story branches, cooking/roleplay steps, science classification and access policy. No runtime LLM or cloud requirement in child play.

## Local data

Drift uses explicit SQL, SQLite schema 2. Upgrade from schema 1 transactionally moves old drawing payloads into `creations` while retaining world, drafts, sessions and installed packs. `world` is a schema-2 metadata aggregate: profile, companion, inventory, progress, settings and memory references. `creations` holds vector strokes/256px thumbnails; `drawing_drafts` holds unfinished work; `session` holds timing; `packs` holds validated definitions/media metadata; `pack_media` holds lazily read asset bytes. Memory-book rows and previews load on demand.

Controller writes serialize and publish only after successful persistence. Completed drawing promotion and pack replacement are transactions. Reset clears every local table and invalidates in-flight downloads. Version-1 world payloads also migrate to the companion schema without dropping memories.

## Parent boundary

Salted PBKDF2-HMAC-SHA256 PINs and retry state live in secure storage. Parent authorization is temporary and revoked on background. Science C uses a separate scoped 15-minute permit, revoked on screen exit/background. The gate is not a legal identity-verification claim.

`ParentAuth`, `ParentBackend`, `PurchaseStore` and `TokenVault` are replaceable. ParentServices creates network/store adapters only for parent actions; startup reads local entitlement cache only. Default `playtest` keeps the entire approved library open. `live` enables a free sample policy and verified premium access; deep routes enforce the same policy as catalogues. Existing creations remain readable.

Supabase OTP auth stores parent tokens in platform secure storage. Server endpoints verify the Auth user and live session, reject unknown fields, derive ownership from the authenticated user, and record explicit policy consent. PostgreSQL grants and RLS isolate parent reads; sensitive writes and token RPCs are service-only. No child data is accepted.

Google Play purchase/restore events share server verification before local delivery or store acknowledgement. Server checks product, parent account binding, current subscription state and expiry. Receipt hashes enforce ownership atomically; receipt tokens are encrypted with server-held AES-GCM keys. Parent refresh re-verifies Google state. Cached access is bounded to 24 hours and actual term expiry; an unavailable backend preserves local play. Store cancellation happens in Google Play, independently of account deletion.

## Content and audio

A bounded HTTPS JSON pack supports definitions, manifest, rewards and inline media. Identity, version, whole-pack SHA-256, schema, media hashes and asset references validate before atomic activation. Corrupt installed metadata is quarantined; bundled content remains usable. Media is split from active metadata and verified again when loaded. Audio has independent music/effects/voice controls and music ducking under authored narration. No microphone or online TTS.

## Verification

The v0.7.5 presentation adapter uses compressed original WebP rooms, a transparent Milo sprite, expression/prop atlases and bounded shared Flame textures. `ui/illustrated.dart` owns scene, atlas and puzzle-symbol rendering; domain engines and SQLite schemas remain independent of artwork. World objects route to the existing activities. Device and parent reduced-motion settings both suppress mascot movement. Scene narration stops on navigation and retains independent voice/music/effects settings.

`test/visual_review_test.dart` captures 21 screen states at 360×640, 430×932, 1000×900 and 150% text. CI loads real fonts, fails on layout exceptions and retains screenshots alongside coverage. These are review evidence, not automatically approved golden baselines. Physical frame time, battery and GPU memory need Android device profiling.

GitHub Actions installs the pinned Flutter/Java toolchain and Supabase CLI. It runs PostgreSQL ownership/privilege tests, portable server tests, content checks, strict analysis, Flutter unit/widget/restart/migration tests and APK build. No generated Drift source is required. The build manifest and release tag identify the tested source, including retained formatting/lock/wrapper inputs. Device/store acceptance testing is distinct from CI.
