# Approved execution contract: v0.2 through v0.7

MILO & ME

ASTRA MEDIUM — AUTONOMOUS EXECUTION BRIEF

Build Continuation: v0.2.0 → v0.7.0

Existing v0.1.0 working APK is the baseline. Preserve it. Extend it.

EXECUTION MODE: This document is an implementation contract, not a brainstorming brief. Read it once, inspect the existing repository, then execute continuously through v0.7.0. Do not restart the app, do not redesign working flows without a concrete reason, and do not stop between milestones for routine approval.

1. Mission and Authority

You are taking over an existing, functioning Milo & Me Flutter application. The user has installed the current Android APK and reports no material issues. The present experience, visual language, navigation, pet identity, and working systems are therefore the approved baseline.

Continue from the current repository and current Git history. Never regenerate the project from scratch.

Treat GitHub as the permanent source of truth; treat your temporary workspace as disposable.

Preserve working UX and architecture unless an implementation defect, safety problem, or scalability blocker requires a targeted change.

Spend model/context budget on implementation, testing, fixes, and finished assets—not repeated explanations.

Make reasonable professional decisions independently. Do not ask for approval for routine UI, code, naming, spacing, animation timing, data-schema, or refactor decisions.

Proceed automatically from v0.2.0 through v0.7.0 unless a genuine external blocker makes further implementation technically impossible.

2. Product North Star

Milo & Me is not an education app with a pet mascot. It is a child's virtual best friend. Drawing, puzzles, stories, care, dress-up, roleplay, cooking and science are things the child and Milo do together.

Every feature must strengthen at least three of these four principles:

Relationship

Play

Value

Trust

Deepens the bond with Milo

Fun without needing to call it learning

Creates, thinks, imagines or discovers

Safe enough for a parent to trust

3. Non-Negotiable Safety and Product Rules

Target age: approximately 5–8 years.

No ads, targeted advertising, behavioural advertising, public chat, stranger interaction, loot boxes, gambling mechanics, manipulative streak-loss, guilt mechanics, fake scarcity or purchase pressure aimed at children.

No child email/password/social account. Parent owns any cloud account; child profile is local-first.

No unnecessary personal data, precise location, contacts, advertising identifiers, camera-roll access, or raw child voice retention.

Runtime experiences must remain useful offline. Network loss must not destroy progress or creations.

Avoid unrestricted generative-AI conversation with the child through v0.7.0.

Real-world science activities must be explicitly safe and parent-gated where adult help is needed.

Care systems must never punish absence or tell the child Milo suffered because they were away.

4. Global Engineering Rules

Framework: Flutter/Dart. Use Flame for game-like 2D interactions only where it adds value.

State: Riverpod. Navigation: go_router. Local persistence: Drift/SQLite. Secure parent credentials/tokens: platform secure storage.

Use data-driven content definitions. Adding a story, drawing lesson or puzzle level should not require creating a new screen.

Keep domain logic separated from rendering and widgets.

Keep content/provider abstractions replaceable; do not couple the app irreversibly to one backend vendor.

Every meaningful milestone must compile, test, commit and push before moving on.

Never commit API keys, service-role secrets, keystores, signing passwords, private credentials or local .env files.

5. Version Sequence

Version

Stage

Primary Objective

Exit Gate

v0.2.0

Companion Core

Make Milo feel persistent, alive and personally connected.

Green CI + working APK + persistent pet memory.

v0.3.0

Engine & Content

Finish reusable drawing, puzzle and story engines; scale core content.

Green CI + target content library + APK.

v0.4.0

World Expansion

Turn the home into a richer explorable environment.

Functional multi-area home + persistent world changes.

v0.5.0

Cooking & Roleplay

Add two new play pillars connected to Milo and wardrobe.

Reusable cooking + roleplay systems + content.

v0.6.0

Science & Offline World

Add safe discovery and real-world exploration.

Digital science + parent-assisted offline activities.

v0.7.0

Parent, Backend & Premium

Productionise parent account, consent, packs, entitlement and subscriptions.

Backend-integrated release-quality milestone.

6. v0.2.0 — Companion Core

Objective: deepen Milo before expanding breadth. This milestone is successful only if the child experiences Milo as a continuing companion rather than a static animated menu.

6.1 Pet State and Personality Engine

Implement/complete internal state for mood, energy, curiosity, affection, recent activity, recent topic, current outfit, care state, development stage, recent reward, world state and last interaction time.

Do not expose these as stressful meters. State should primarily appear through behaviour, animation, dialogue and suggestions.

Create deterministic contextual logic: Context + PetState + RecentActivity + Time/Session + WorldState → reaction/dialogue/suggestion.

Implement repetition control so Milo does not cycle the same greeting or suggestion excessively.

Add session-aware greetings and return-after-absence greetings without guilt.

6.2 Milo Memory

Persist safe memories on-device: child nickname, Milo name, drawings, completed stories, puzzle milestones, outfits, rewards, favourite categories inferred locally, and meaningful firsts.

Support contextual callbacks such as referencing a prior drawing, completed story or reward.

Memory callbacks must be occasional, natural and bounded—not creepy or overly specific.

Store schema/version information so memory can migrate safely in future releases.

6.3 Pet World Persistence

Allow child creations and rewards to leave visible traces in Milo's home.

Examples: framed drawing/poster, shelf reward, unlocked toy/decor, equipped outfit.

World state must survive app restart and offline use.

Avoid clutter: use curated display slots and rotation rather than placing unlimited objects simultaneously.

6.4 Animation and Reactivity

Add or refine idle breathing, blink, look-around, short walk, sit, jump, laugh, surprise, curiosity, sleepy, eating, washing, affection reaction and happy-dance states.

Pet should feel alive while idle but never visually frantic.

Respect reduced-motion settings where supported.

If final Rive assets are unavailable, keep a clean animation abstraction and use production-quality temporary assets rather than blocking progress.

6.5 v0.2.0 Exit Criteria

1.  Fresh install → onboarding → Milo home works.

2.  Pet state survives restart.

3.  At least three different prior activities can be remembered and referenced.

4.  At least one drawing/reward visibly persists in the world.

5.  Care and wardrobe remain functional.

6.  Static analysis and automated tests pass.

7.  Android APK builds successfully in CI.

8.  Commit/tag the milestone and upload the APK artifact before starting v0.3.0.

7. v0.3.0 — Core Engines and Content

Objective: turn the three V1 pillars into scalable content engines. New content should mostly be data, assets and authoring—not new Flutter screen logic.

7.1 Drawing Engine 1.0

Support Watch, Draw With Me and Create modes.

Guided stroke playback, step progression, pause/replay where useful, undo, redo, eraser, clear, brush sizes, limited child-friendly palette, save, thumbnails and local gallery.

Provide narration/audio hooks without making cloud services mandatory.

Store lesson definitions in structured content data.

Integrate creations with Milo memory and world display.

Target approximately 24 guided drawing lessons by the end of v0.3.0. Prefer diverse high-quality lessons over filler.

7.2 Puzzle Engine 1.0

Build reusable engines: Match, Sort, Sequence, Spatial and Logic.

Puzzle definition must be data-driven and validated.

Add visual/audio feedback, retry, completion state, rewards and progress persistence.

Contextualise puzzles through Milo situations where practical instead of worksheet presentation.

Target approximately 50–60 levels across the reusable engines.

7.3 Interactive Story Engine 1.0

Structured scene model supporting narration, background, character state, Milo expression/animation, dialogue, choice, branch, interaction, reward, memory, resume and completion.

Support branching without hardcoding every story in widgets.

Store story state locally and allow safe resume after process death/restart.

Target approximately 10–12 polished interactive stories. Themes may include space, ocean, friendship, animals, courage, nature, imagination, mysteries and kindness.

7.4 Progression and Rewards

Add meaningful milestones without competitive pressure.

Examples: first drawing, first story, first puzzle family, first themed set, creativity milestone, kindness/story milestone.

Reward primarily with world objects, wardrobe items, memory-book moments and new experiences—not currencies designed for grinding.

7.5 Initial Theme Packs

Introduce a clean content taxonomy for at least: Dinosaurs, Space, Ocean, Animals and Nature.

Content may remain bundled locally at this stage, but it must already conform to the future downloadable-pack schema.

7.6 v0.3.0 Exit Criteria

1.  All three engines are reusable and data-driven.

2.  Target core content library is substantially present and playable.

3.  New lesson/level/story can be added without adding a dedicated screen.

4.  Progress, reward and resume state survive restart/offline use.

5.  Tests cover engine logic and persistence.

6.  Green CI + APK artifact + Git milestone before v0.4.0.

8. v0.4.0 — World Expansion

Objective: evolve Milo's home from a single functional screen into a small, coherent, premium explorable world—without attempting a giant open world.

Bedroom: sleep, wardrobe, memory objects.

Art Corner/Studio: drawing entry and displayed creations.

Story Corner: story library and recent story objects.

Puzzle/Play Corner: puzzles and unlocked toys.

Care Area: food/care interactions.

Garden: first expansion area and bridge to future science/nature content.

8.1 Interaction Model

Prefer environmental taps over dashboard-style feature cards.

Preserve clear child usability: interactive areas must be visually discoverable and not depend on reading labels.

Milo can move/transition between selected areas; avoid expensive free-roaming pathfinding unless it clearly improves experience.

World changes should reflect child history but use bounded display slots for performance and clarity.

8.2 v0.4.0 Exit Criteria

1.  Child can navigate all major world areas without parent-level text navigation.

2.  Existing drawing/puzzle/story/care flows remain intact.

3.  At least several progress-dependent world changes are visible.

4.  Phone and tablet layouts remain coherent.

5.  Green CI + APK artifact + Git milestone before v0.5.0.

9. v0.5.0 — Cooking and Roleplay

Objective: add two new play pillars, both linked to Milo rather than appearing as unrelated mini-games.

9.1 Cooking Engine

V0.5 focuses on virtual cooking only.

Reusable actions: choose ingredient, pour, mix, spread, decorate, assemble, simple timing/sequence and serve.

Do not simulate dangerous real cooking procedures for the child.

Seed recipes may include pancakes, sandwich, fruit bowl, pizza and cake.

Completion can create memories, unlock kitchen objects or trigger Milo reactions.

Architecture must permit safe parent-assisted real recipes later without coupling them to child-only gameplay.

9.2 Roleplay Engine

Initial roleplay themes: astronaut, chef, doctor, artist, detective and builder.

Connect wardrobe state to roleplay suggestions. Example: astronaut outfit can trigger a space adventure prompt.

Roleplay should use simple situational sequences, choices and interactive props rather than long text.

No medical or safety claims; doctor play is pretend play only.

9.3 v0.5.0 Exit Criteria

1.  Cooking is a reusable system, not five one-off screens.

2.  Roleplay is a reusable scenario framework.

3.  Wardrobe meaningfully connects to at least several roleplay/activity suggestions.

4.  Milo remembers selected cooking/roleplay milestones.

5.  Green CI + APK artifact + Git milestone before v0.6.0.

10. v0.6.0 — Science and Offline World

Objective: add curiosity/discovery while making Milo & Me one of the rare children's apps that intentionally sends children back into the real world.

10.1 Science Categories

Level A — fully digital exploration inside the app.

Level B — safe real-world observation using ordinary household objects.

Level C — parent-assisted activity behind an explicit parent gate.

10.2 Initial Science Themes

Colour mixing.

Light and shadow.

Sink or float.

Plant growth basics.

Simple magnets.

Weather/water-cycle concepts.

Pattern observation in nature.

10.3 Real-World Exploration

Examples: find three red objects; collect three leaf shapes; predict which safe household objects float; look for shadows at different times.

Activities must work without camera/location permission unless a later reviewed feature truly requires them.

No open flame, sharp tools, dangerous chemicals, ingestion tasks, high electricity or unsafe experiments.

Parent-assisted activities must clearly state the adult's role.

10.4 Session Philosophy

Add healthy natural endpoints such as suggesting paper drawing, building with blocks or observing something in the room.

Never shame or force the child to leave the app; suggestions are friendly and optional.

10.5 v0.6.0 Exit Criteria

1.  Digital science activities are data-driven and reusable.

2.  At least one safe real-world activity flow exists with correct gating.

3.  Offline discovery tasks do not require sensitive device permissions.

4.  Science/reality activities integrate with Milo memory/rewards.

5.  Green CI + APK artifact + Git milestone before v0.7.0.

11. v0.7.0 — Parent, Backend, Content Delivery and Premium

Objective: productionise the adult side and cloud infrastructure while preserving the child's local-first experience. If credentials or store products are unavailable, implement every code/configuration layer possible and leave only the external credential/console action blocked.

11.1 Parent Zone

Parent gate using device biometric/PIN where practical, with a safe adult-challenge fallback.

Parent home with simple local progress summary: creativity, stories, logic, topics explored and recent milestones.

Profile management, privacy, consent, permissions, downloads, language, music/SFX/voice controls, accessibility/session preferences, data reset/delete and help/about.

No competitive child ranking or comparison to other children.

11.2 Backend — Supabase

Parent authentication only; no child cloud login.

PostgreSQL models for parent account, consent record, entitlement, content catalogue/version metadata and optional backup metadata.

Use row-level security and server-side validation. Child clients must not receive unrestricted database access.

All secrets via environment variables / GitHub secrets; commit only .env.example and safe public configuration.

If live Supabase credentials are unavailable, implement schemas/migrations/adapters, local mocks and integration tests so activation requires configuration rather than architecture work.

11.3 Content Packs and Object Storage

Implement versioned downloadable content-pack schema compatible with object storage such as Cloudflare R2.

Pack contains manifest + drawings + puzzles + stories + audio + backgrounds + rewards + metadata as applicable.

Validate checksum/schema/version before activation. Failed/corrupt pack must not break the app.

Downloaded packs must work offline after successful installation.

Provide safe fallback to bundled content.

11.4 Entitlement and Premium

Use parent-only purchase entry points.

Prepare/store integration through Flutter in-app-purchase architecture and backend entitlement verification.

Support monthly and annual product identifiers through configuration, not hardcoded scattered values.

Support restore purchases.

If App Store/Play Console product IDs or signing credentials are unavailable, provide production-ready adapters plus deterministic sandbox/mock entitlement so the app remains testable.

Never place 'ask your parent to buy' pressure inside the child experience.

11.5 Free/Premium Product Model

Free: Milo, core room, core care, limited dress-up, sample drawings, sample puzzles and 1–2 stories.

Premium: full drawing/puzzle/story library, premium content packs, cooking, roleplay, science and future world expansions.

Keep pricing remote/configurable. Current India hypothesis: ₹199–₹249/month and ₹1,299–₹1,499/year; do not hardcode final pricing into child-facing logic.

11.6 Privacy and Data Deletion

Make local data reset/delete reliable and explicit in Parent Zone.

If optional cloud backup exists, parent must control it and be able to disable/delete it.

Do not upload raw child voice recordings by default.

Avoid third-party behavioural analytics inside child mode.

11.7 v0.7.0 Exit Criteria

1.  Parent Zone is complete and protected.

2.  Local-first child experience works with backend unavailable.

3.  Backend schema/adapters and secure access rules are implemented.

4.  Content packs can be validated, installed, versioned and used offline.

5.  Premium entitlement architecture and restore flow are implemented/testable.

6.  Privacy/reset/delete flows are implemented.

7.  Green CI + successful Android APK artifact.

8.  Commit and tag v0.7.0 with concise release notes and known external blockers only.

12. Cross-Milestone Quality Gates

At the end of every version (v0.2.0 through v0.7.0), perform all applicable gates before continuing:

1.  Run dependency restore/code generation.

2.  Run formatter where appropriate.

3.  Run static analysis.

4.  Run unit/widget/integration tests available in the environment.

5.  Build Android APK through GitHub Actions.

6.  Inspect CI failures and fix them; do not merely report the first error.

7.  Upload APK as a workflow artifact.

8.  Commit all source/docs/schema changes with a meaningful message.

9.  Tag or otherwise clearly mark the milestone in Git.

10.  Push before beginning the next version.

13. Required Test Coverage

Pet state transitions and repetition control.

Memory creation, retrieval and migration.

World persistence.

Drawing save/load and lesson parsing.

Puzzle engine definitions, completion and malformed-content handling.

Story branching, resume, choice persistence and completion.

Inventory/wardrobe and reward persistence.

Cooking/roleplay scenario parsing.

Science safety classification and parent-gate routing.

Content-pack schema, validation, versioning and corrupted-pack fallback.

Parent-gate flows.

Entitlement/restore behaviour using test/mocked stores where live stores are unavailable.

Database migrations and app restart/offline scenarios.

14. Performance and UX Requirements

Optimise for ordinary mid-range Android phones and tablets.

Avoid loading entire content libraries or high-resolution assets into memory at once.

Use lazy loading and appropriate compression.

Drawing must remain responsive under long strokes and repeated undo/redo.

Animations must remain smooth without continuous unnecessary background work.

Music must duck under narration; parent can control music, SFX and voice independently.

Do not replace the approved premium child-friendly visual direction with generic Material defaults.

Keep tap targets large, reading requirements low, and feedback understandable without text whenever possible.

15. Documentation to Maintain in Repository

README.md — concise setup, build, current milestone and quick architecture.

docs/PRODUCT_FOUNDATION.md — product philosophy and non-negotiable rules.

docs/ARCHITECTURE.md — technical/module/data architecture.

docs/ROADMAP.md — versions and completion state.

docs/PRIVACY_AND_CHILD_SAFETY.md — child/privacy rules and data map.

docs/CONTENT_SYSTEM.md — drawing/puzzle/story/content-pack schemas.

docs/RELEASE_NOTES.md or versioned release notes — what changed and known limitations.

Keep documentation concise. Do not spend large portions of context rewriting the same product philosophy after each milestone.

16. Context/Limit Efficiency Rules

The user's priority is to maximise implementation per Astra usage limit. Use internal reasoning and tools quietly. Do not produce long progress essays. Short checkpoints are enough; code, assets, testing and builds are the work.

Do not stop after planning.

Do not ask 'should I proceed?' between versions.

Do not re-explain the full architecture unless a change is genuinely necessary.

Batch related work before reporting status.

When multiple valid approaches exist, choose one and implement.

Prefer reusable engines/content schemas over duplicated one-off features.

If context/time is approaching a hard limit, prioritise leaving the repository compiling, pushed and clearly checkpointed rather than beginning an unfinished major subsystem.

If a genuine external blocker appears, complete everything that does not depend on that blocker, isolate it behind an interface/mock, document the exact missing credential/action in one concise note, then continue with unaffected work.

17. Definition of Done for This Assignment

Do not consider this assignment complete merely because source files exist.

1.  The existing v0.1.0 app remains functional and recognisable.

2.  v0.2.0 Companion Core is implemented and validated.

3.  v0.3.0 reusable engines/content milestone is implemented and validated.

4.  v0.4.0 world expansion is implemented and validated.

5.  v0.5.0 cooking and roleplay are implemented and validated.

6.  v0.6.0 science and offline-world activities are implemented and validated.

7.  v0.7.0 parent/backend/content-delivery/premium architecture is implemented to the maximum technically possible.

8.  Each milestone has been committed/pushed and verified through CI.

9.  The final repository is clean of secrets and generated junk.

10.  A latest successful Android APK is available as a CI artifact.

11.  Known limitations list contains only real unresolved blockers, not unimplemented routine work that could have been completed.

18. Start Command

BEGIN NOW. Inspect the current Milo & Me repository and v0.1.0 implementation first. Do not recreate the project. Establish the exact current state from source and Git history, then implement v0.2.0. After v0.2.0 passes its exit gate and is pushed, proceed directly to v0.3.0, then v0.4.0, v0.5.0, v0.6.0 and v0.7.0. Do not wait for another user instruction between these stages.

END OF EXECUTION BRIEF
