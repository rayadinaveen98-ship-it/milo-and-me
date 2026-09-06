# Privacy and child safety rules

These are engineering/product rules, not a certification of legal compliance.

## Local by default

Keep nickname, pet profile/state, drawings, memories, progress, preferences and local history in app-private storage. No child login, email, phone or social account. No ads, behavioural advertising, analytics of every child tap, public chat or stranger interaction. Do not request location, contacts, camera or microphone for the current app. Android automatic backup is disabled. The permission manifest must reflect actual features.

## Parent authority

Use a parent gate for settings, purchases, permissions, downloads, cloud accounts and data deletion. The current six-digit PIN is salted/PBKDF2 hashed in platform secure storage, with persisted retry throttling and foreground-only authorization. It is not proof of adult identity or verified legal consent. Verify any legally required consent before enabling relevant collection or services.

No purchases or subscription prompts in child flows. Store entitlements must be validated server-side; a client cannot grant itself premium access. Never commit tokens, API secrets, parent data, signing keys, test-device exports or production database dumps.

## Healthy emotional design

No absence punishment, sickness caused by leaving, guilt, streak-loss pressure, artificial scarcity, loot boxes, paid energy or rankings. Offer calm breaks and offline play. Feedback should encourage another try. Screen-time controls support parents; do not market them as an OS-level security boundary.

## Voice and content

Prefer authored local audio. Voice input, if introduced, needs parent choice, supported on-device processing and tap alternatives. Do not save raw child recordings by default. No unrestricted cloud chatbot in V1. Validate downloaded content, branch targets, identities and checksums before activation; retain installed content on failure. Editorially review age suitability and factual/offline-activity safety.

## Cloud boundary and deletion

Optional cloud services are parent-owned: auth, consent, entitlement, catalogue/version and backup metadata. Never send child creations by default. Optional backup requires an explicit reviewed encryption/key-recovery design. Enable RLS and narrow grants for every exposed table; test cross-parent access denial. Local reset must delete the world, creations/drafts, progress and downloaded packs. Cloud deletion must be implemented before cloud accounts are offered.

Before release, review Google Play Families, Apple Kids Category, applicable Indian privacy rules and COPPA-style obligations for actual distribution territories and data flows. Current source is a supervised playtest milestone, not a store-ready compliance claim.
