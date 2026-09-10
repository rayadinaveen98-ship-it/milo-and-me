# Release notes

## 0.2.0 — Companion Core

Persistent companion state, firsts and keepsake slots; v1 save migration; contextual dialogue with bounded repetition; warm return greetings; expanded reactive/idle pet animation respecting reduced motion. Five new tests cover callbacks, repetition, migration and restart persistence. Existing onboarding, activities and wardrobe are preserved.

Verified in CI run 34042238697; tag v0.2.0 and direct APK published.

## 0.3.0 — Core engines and content

24 drawings, 55 puzzles, 12 original branching stories across Dinosaurs, Space, Ocean, Animals and Nature. Lazy themed catalogues with lesson previews; drawing pause/resume and cheaper live-stroke repaint; drag/tap puzzle answer spaces; persistent interactive story props; creativity/theme/kindness keepsakes. Full bundled library remains available in the offline playtest. Verified: CI 34043370987, 38 Flutter tests, tag/APK v0.3.0.

## 0.4.0 — Our little world

Six connected environmental areas, persistent last area and bounded reward decorations. Art studio can rotate saved pictures, with the choice shared by the original home. Existing home, care and activities remain accessible. Responsive phone/tablet rooms; reduced-motion transitions. Verified: CI 34044241950, 41 Flutter tests, tag/APK v0.4.0.

## 0.5.0 — Cooking and roleplay

Reusable stateful scenario engine with persisted steps/choices, repeat actions, bounded pretend timing, props and replay. Five virtual recipes; astronaut, chef, toy doctor, artist, detective and builder scenarios. World/wardrobe entry points, new costumes, pet callbacks and idempotent memories. All cooking and doctor play is explicitly pretend. Verified: CI 34077648721, 46 Flutter tests, tag/APK v0.5.0.

## 0.6.0 — Little discoveries

Seven reusable digital science themes; two optional seated observation activities and one parent-assisted leaf/paper-outline flow. Reviewed offline instructions, scoped PIN permission revoked on background/exit, no sensitive permissions or proof collection. Local progress, memories and explorer keepsake; gentle optional paper/block suggestions. Verified: CI 34078295263, 52 Flutter tests, tag/APK v0.6.0.

## 0.7.0 — Parent services and dependable local play

Protected parent account/library/store controls, explicit account consent, OTP token storage, configurable Google Play products and server-verified purchase/restore. Owner-isolated Supabase schema and server API, encrypted receipt tokens, PostgreSQL and portable server tests. Atomic versioned media packs, corruption fallback, lazy media/gallery, real schema-1 artwork migration and reliable local reset. Full offline playtest remains the default; live free/premium policy also protects direct routes. CI pending.

External activation requirements: Supabase/SMTP and deployed credentials, published catalogue/storage, Play Console products/service account/testers, and stable signing. See BACKEND_ACTIVATION.md. No live store or device acceptance is claimed by CI.
