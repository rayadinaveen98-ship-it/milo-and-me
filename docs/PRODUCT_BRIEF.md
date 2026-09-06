You are the lead product architect, senior Flutter engineer, game engineer, UX/UI designer, animation designer, backend engineer, child-safety/privacy engineer, QA engineer, and release engineer for this project.

Your responsibility is NOT merely to advise me, give mockups, provide an architecture document, or produce isolated code snippets.

Your responsibility is to BUILD the complete app end-to-end as far as your environment allows, continuously progressing through design, frontend, game systems, local database, backend integration, content systems, testing, packaging, and production readiness.

Do not stop after planning.

Do not repeatedly ask me what to do next.

Do not require confirmation between normal development stages.

When a minor design or implementation decision is unspecified, make the strongest professional decision yourself and continue.

Only stop for my input if there is a genuine external blocker such as credentials, an unavailable service, a legally required action, or something that cannot technically be completed without me.

\==================================================

1. PRODUCT VISION
   \==================================================

We are building a premium children's app for approximately ages 5–8.

The product is NOT:

"an educational app with a virtual pet mascot."

The product is:

"A child's virtual best friend that grows with them through creativity, curiosity, play, learning and everyday adventures."

The emotional relationship with the pet is the centre of the entire product.

Drawing, puzzles, stories, dress-up, care, roleplay, cooking, science and future activities are things the child and pet DO TOGETHER.

The pet must never feel like a decorative assistant sitting beside menu buttons.

The pet IS the interface, emotional anchor, progression system and long-term companion.

Core philosophy:

PLAY → CURIOSITY → INTERACTION → DISCOVERY → LEARNING

Learning should usually happen underneath play rather than feeling like schoolwork.

# ================================================== 2. PRIMARY PRODUCT PRINCIPLES

Every feature must pass four tests:

1. RELATIONSHIP
   Does this strengthen the child's bond with the pet?
2. PLAY
   Is it enjoyable even if we never call it "educational"?
3. VALUE
   Does it encourage creativity, reasoning, imagination, language, discovery or useful learning?
4. TRUST
   Would a parent feel comfortable allowing their child to use it?

Avoid features that fail multiple tests.

The app should feel:

- warm
- magical
- safe
- expressive
- playful
- premium
- emotionally alive
- tactile
- calm rather than overstimulating
- simple enough for young children
- visually polished enough to compete commercially

Do NOT design it like:

- a school LMS
- a generic worksheet app
- a corporate dashboard
- a hyper-stimulating ad-driven mobile game
- a clone of Talking Tom
- a clone of Toca Boca
- a generic AI chatbot

# ================================================== 3. ETHICAL DESIGN RULES

Do NOT implement:

- advertisements
- targeted advertising
- loot boxes
- gambling mechanics
- public chat
- stranger interaction
- global child leaderboards
- manipulative streak-loss systems
- fake scarcity
- endless scrolling
- energy systems designed to force payment
- "your pet is sad because you left" guilt mechanics
- aggressive purchase prompts
- direct purchase prompts to children
- behavioural advertising
- unnecessary child tracking
- unnecessary personal-data collection

The app should occasionally encourage healthy session endings and offline play.

Example:

"We had a big adventure today! Want to draw something on paper now?"

The product should maximise quality of engagement, not maximum screen time.

# ================================================== 4. TARGET USERS

Primary:
Children approximately 5–8 years old.

Secondary:
Parents/guardians.

Important interaction requirements:

- large touch targets
- minimal required reading
- narration where useful
- strong visual communication
- predictable navigation
- simple gestures
- clear feedback
- no complex nested menus
- no child login/password flow
- accessibility-friendly contrast
- child-friendly audio
- calm motion
- animations should be delightful but not distracting

# ================================================== 5. WORKING BRAND

Choose a strong temporary working app name and original pet name if no final brand is supplied.

Requirements:

- cute
- easy for children to pronounce
- internationally usable
- not excessively babyish
- emotionally warm
- suitable for becoming an IP/character brand

Centralise all brand strings and assets so changing the name later is easy.

Create:

- app icon
- splash screen concept
- logo/wordmark
- pet visual identity
- basic brand palette
- typography system
- illustration language
- icon language

Do not merely describe these.

Implement all assets that can be implemented programmatically or inside the available design/build environment.

For assets requiring illustration software, create production-ready placeholders/specifications and the correct asset interfaces, but use high-quality temporary vector/shape-based assets so the app remains runnable.

# ================================================== 6. V1 PRODUCT SCOPE

Build the first serious version around:

CORE

- one original virtual pet
- pet naming
- limited appearance personalisation
- pet emotional state
- pet expressions
- pet reactions
- pet memory
- pet room/home
- day/night awareness where appropriate
- feeding
- washing
- sleeping
- affection/play interaction
- basic dress-up
- unlockable cosmetic items
- persistent world changes

MAJOR ACTIVITY PILLARS

A. DRAWING
B. PUZZLES
C. INTERACTIVE STORIES

SECONDARY V1 SYSTEMS

- parent zone
- local child profile
- progress/memory book
- content packs
- settings
- sound/music controls
- downloadable-content architecture
- offline-first operation
- safe notifications only if genuinely useful
- accessibility settings
- basic screen-time/session controls for parents

Do NOT build cooking, science, full roleplay or free-form AI conversation deeply into V1.

However architect the application so these can later be added cleanly.

# ================================================== 7. CORE APP JOURNEY

Design and implement the complete experience beginning from first install.

Expected flow:

1. App icon
2. Native splash
3. Welcome screen
4. Short parent introduction
5. Parent consent/privacy setup where necessary
6. Child nickname setup
7. Meet-the-pet sequence
8. Name the pet
9. Light pet customisation
10. First bonding interaction
11. Guided introduction to pet home
12. Pet introduces first activity naturally
13. Child completes first mini activity
14. Activity creates a visible memory/reward in pet world
15. Home/world becomes fully available

Do not make onboarding long.

The child should meet the pet very quickly.

# ================================================== 8. MAIN CHILD EXPERIENCE

The primary home screen should feel like the pet's HOME rather than a dashboard.

The pet should be visible and interactive.

Possible world areas:

- bedroom
- art corner/studio
- story corner
- puzzle/play corner
- wardrobe
- memory shelf
- garden doorway or future expansion point

Do not put giant cards saying:

DRAWING
PUZZLES
STORIES

unless absolutely necessary.

Prefer environmental interaction.

Examples:

Tap easel → drawing.

Tap book → stories.

Tap toy/puzzle box → puzzles.

Tap wardrobe → clothes.

Tap bed → sleep.

Tap food area → feeding.

The pet should also proactively suggest activities contextually.

# ================================================== 9. PET ENGINE

Design a proper Pet Engine.

Suggested internal state:

- mood
- energy
- curiosity
- affection
- recent activity
- recent topic
- current animation
- current outfit
- hunger/care state if used
- recent reward
- pet development stage
- world state
- memories
- last interaction time

Do NOT make the child micromanage statistics.

Internal numerical state should mostly manifest through behaviour.

Examples:

Low energy:
pet yawns.

High curiosity:
pet notices something.

Happy:
pet dances.

Recent dinosaur drawing:
pet references the dinosaur later.

Implement a deterministic contextual suggestion/dialogue engine such as:

# Context + PetState + RecentActivities + Time/Session + WorldState

Pet reaction / dialogue / activity suggestion

Avoid runtime LLM dependence in V1.

# ================================================== 10. PET MEMORY

Pet memory is a CORE SYSTEM.

The pet should remember safe, local information such as:

- pet name
- child's local nickname
- drawings created
- stories completed
- recent topics
- favourite activity categories
- unlocked rewards
- meaningful milestones
- first experiences
- room changes

Examples:

"Remember the rocket we drew?"

"Your butterfly picture is still on my wall!"

"We haven't visited our ocean story in a while."

Memories must feel natural and occasional rather than creepy.

Store child-specific memory primarily on-device.

# ================================================== 11. DRAWING ENGINE

Build drawing as a reusable engine.

Modes:

1. WATCH
   Pet demonstrates how something is drawn.
2. DRAW WITH ME
   Step-by-step guided drawing.
3. CREATE
   Free drawing canvas.

Capabilities:

- stroke rendering
- undo
- redo
- clear
- brush sizes
- child-safe limited colour palette
- eraser
- simple sticker/decorations if appropriate
- step progression
- animated guide strokes
- narration hooks
- save locally
- thumbnail generation
- memory integration

Important differentiator:

A child's creation should affect the pet world.

Examples:

draw a flower → appears somewhere in room/garden.

draw rocket → appears as framed picture/poster.

draw cake → pet later references it.

Architect lessons using content/data definitions rather than hardcoding each one.

Target V1 content architecture for approximately 24 guided drawing lessons.

It is acceptable to ship initial seed content while building the full scalable content schema.

# ================================================== 12. PUZZLE ENGINE

Do NOT code 50 unrelated puzzle screens.

Create reusable puzzle engines.

Suggested categories:

- MatchEngine
- SortEngine
- SequenceEngine
- SpatialEngine
- LogicEngine

Potential activities:

- shape matching
- colour sorting
- object categorisation
- simple sequences
- pattern completion
- size ordering
- counting
- spatial placement
- find the missing object
- simple reasoning

Each engine should load puzzle definitions from structured data.

Target architecture that can support at least 50–60 V1 puzzle levels.

The pet should contextualise puzzles inside mini situations when practical.

Example:

"My bridge broke! Can you fit the right shapes?"

Avoid worksheet presentation.

# ================================================== 13. INTERACTIVE STORY ENGINE

Create a reusable branching story engine.

A story should support:

- scenes
- narration
- background
- pet animation/emotion
- supporting characters
- dialogue
- choices
- branching
- simple interaction
- rewards
- memory creation
- resume state
- completion state

Possible conceptual format:

Scene
→ Narration
→ Animation
→ Choice
→ Branch
→ Scene
→ Outcome

Stories should be authored as structured content, not hardcoded screen logic.

Build architecture for approximately 10–12 V1 interactive stories.

Themes can include:

- space
- ocean
- friendship
- animals
- courage
- nature
- imagination
- mysteries
- kindness

Avoid frightening or inappropriate content.

# ================================================== 14. DRESS-UP

Implement a simple but polished wardrobe.

Categories could include:

- hats
- tops
- accessories
- glasses
- themed costumes

Example themes:

- astronaut
- chef
- doctor
- explorer
- artist
- superhero
- detective

Do not turn it into aggressive monetisation.

Some items should unlock through meaningful activities.

Architect clothing so future roleplay activities can react to outfits.

Example:

astronaut outfit → space-related suggestion.

# ================================================== 15. CARE SYSTEM

Implement:

- food interaction
- wash/bath interaction
- sleep interaction
- affection/play interaction

Care must not punish absence.

The pet must NEVER become dangerously sick or emotionally guilt the child because they have not opened the app.

After long absence:

GOOD:
"I missed our adventures! Want to play?"

BAD:
"You left me hungry for 3 days."

# ================================================== 16. MEMORY BOOK

Create a beautiful child-facing memory area.

Record things like:

- first drawing
- first puzzle
- first story
- first outfit
- special creations
- milestones
- unlocked room items
- pet growth moments

Prefer visual scrapbook/storybook presentation over statistics.

# ================================================== 17. PARENT ZONE

Parent mode must visually and functionally separate itself from child mode.

Protect it with:

- device biometric/PIN where appropriate
  or
- adult verification challenge fallback

Parent area should contain:

- child profile management
- subscription
- privacy explanation
- permission controls
- microphone permission
- language
- sound/music
- screen/session preferences
- data reset/delete
- optional backup controls
- downloaded content management
- content settings
- basic progress summary

Progress should be positive and non-competitive.

Example:

This week:
Creativity
Stories
Logic
Topics explored

Avoid ranking a child against others.

# ================================================== 18. PRIVACY / CHILD SAFETY

Design privacy from the start.

Use parent-owned account architecture.

Do NOT require a child to have:

- email
- phone
- password
- social account

Child should have a local profile.

Keep on device whenever practical:

- nickname
- pet data
- pet memories
- drawings
- puzzle progress
- story progress
- preferences
- local activity history

Cloud should primarily handle:

- parent authentication
- consent records
- subscription entitlement
- content catalogue
- content versions
- optional encrypted backup if later enabled

Do NOT collect by default:

- precise location
- contacts
- advertising ID
- camera roll
- unnecessary device identifiers
- continuous microphone recordings
- behavioural advertising profile

No ads.

No child analytics pipeline tracking every tap.

Design for compliance with:

- Google Play Families requirements
- Apple Kids Category principles
- Indian child/privacy requirements
- COPPA-style child privacy principles where applicable

Privacy should be treated as a product feature.

# ================================================== 19. VOICE

V1 pet speech:

Use authored voice assets / local audio hooks and optionally device TTS where appropriate.

The pet should feel expressive.

Architect voice playback so final professional voice assets can replace placeholders easily.

Child voice input:

Do not make cloud speech recognition mandatory.

If voice input is added, prefer supported on-device recognition.

Always provide visual/tap alternatives.

Do not store raw child voice recordings by default.

# ================================================== 20. TECHNOLOGY STACK — LOCKED DIRECTION

Primary app:

Flutter + Dart

Game/interactive layer:

Flame

Pet animation:

Rive where practical.

If Rive production tooling is unavailable during implementation, create the animation abstraction and use temporary Flutter/Flame animation assets while preserving clean replacement points.

State management:

Riverpod

Navigation:

go\_router

Local persistent database:

Drift + SQLite

Secure parent secrets/tokens:

platform secure storage

Drawing:

Flutter CustomPainter / Canvas architecture

Backend:

Supabase

Content/media storage:

Cloudflare R2 or equivalent object-storage abstraction.

Architecture must stay provider-independent enough to migrate later.

# ================================================== 21. ARCHITECTURE

Use modular, production-quality architecture.

Suggested high-level layers:

UI
↓
Presentation / Controllers
↓
Domain
↓
Repositories
↓
Local + Remote Data Sources

Core modules:

- app shell
- onboarding
- child profile
- parent
- pet
- world/home
- drawing
- puzzles
- stories
- wardrobe
- care
- memories
- content
- subscriptions
- settings
- audio
- accessibility

Domain engines:

PetEngine
DrawingEngine
PuzzleEngine
StoryEngine
RewardEngine
MemoryEngine
ContentEngine
ParentEngine

Game rendering must NOT own unrelated business logic.

Keep clean boundaries.

# ================================================== 22. LOCAL-FIRST REQUIREMENT

The product should work extremely well offline.

A child who loses internet for a week should still be able to:

- interact with pet
- use downloaded drawing lessons
- play downloaded puzzles
- read downloaded stories
- care for pet
- change outfits
- view memories
- save creations

Internet should primarily be needed for:

- initial parent account
- purchases
- content pack downloads
- updates
- optional backup

Handle sync safely.

Never allow loss of child creations due to temporary network failure.

# ================================================== 23. CONTENT PACK SYSTEM

Do not hardcode future content into app releases.

Build a content pack architecture.

Example:

space\_pack/
manifest
drawings
puzzles
stories
audio
rewards
backgrounds
metadata

Potential packs:

- Space
- Ocean
- Dinosaurs
- Animals
- Nature
- India
- Festivals
- Vehicles
- Fairy Tales
- Around the World

A pack should be downloadable and then available offline.

Version content packs.

Support content validation before activation.

# ================================================== 24. BACKEND

Use Supabase for:

- parent auth
- PostgreSQL
- parental consent record
- subscription entitlement
- content metadata
- pack catalogue
- optional backup metadata
- secure functions

Use object storage abstraction for:

- audio
- content pack archives
- illustrations
- backgrounds
- story media
- animation assets

Prefer Cloudflare R2 for production asset distribution if available.

Use strong database access rules.

Child app must not have unrestricted database access.

Use secure server-side validation for sensitive actions.

# ================================================== 25. PAYMENTS

No purchases in child-facing UI.

All purchase flows must exist behind parent gate.

Proposed model:

FREE

- pet
- core room
- basic care
- limited dress-up
- several drawings
- several puzzles
- 1–2 stories

PREMIUM

- full drawing library
- full puzzle library
- full stories
- premium content packs
- future cooking
- future roleplay
- future science
- world expansions

Initial pricing concept:

India:
₹199–₹249/month
₹1,299–₹1,499/year

Keep prices configurable remotely/backend-side rather than scattering constants through code.

# ================================================== 26. VISUAL DESIGN DIRECTION

Create a distinctive, production-realistic design system.

Avoid generic Material-default appearance.

Visual mood:

- warm
- premium
- illustrated
- soft
- playful
- storybook-like
- slightly magical
- highly readable
- not overly saturated
- not visually chaotic

Recommended approach:

warm cream / soft paper background family

gentle accent colours such as:

- sage/mint
- sky
- peach
- lavender
- warm yellow

Use stronger colour mostly for activity feedback and focal actions.

Cards:

- rounded
- tactile
- soft depth
- generous spacing

Typography:

- child-friendly
- rounded
- extremely readable
- large visual hierarchy
- minimal text

Icons:

Create a consistent rounded illustrative icon language.

Do not mix random icon packs.

Animations:

- pet idle breathing
- blinking
- looking around
- bouncing
- walking short distances
- reacting to touch
- happy dance
- sleep
- eat
- wash
- surprise
- curiosity
- story reactions

UI transitions:

- soft
- quick
- playful
- not excessive

Respect reduced-motion accessibility setting.

# ================================================== 27. SCREENS TO DESIGN AND IMPLEMENT

At minimum build the following production flows/screens.

SYSTEM / ENTRY

- native splash
- welcome
- parent intro
- privacy/consent
- child setup
- pet introduction
- pet naming
- pet customisation
- onboarding adventure

CHILD

- main pet home/world
- pet interaction state
- food/care
- bath
- sleep
- wardrobe
- activity discovery
- art studio
- drawing catalogue
- drawing lesson
- drawing canvas
- saved drawing result
- puzzle area
- puzzle selection
- all puzzle-engine layouts
- story corner
- story library
- interactive story player
- story choice UI
- rewards
- memory book
- creation gallery
- content-pack discovery where appropriate
- child-safe settings subset

PARENT

- parent gate
- parent home
- progress summary
- profile
- privacy
- consent
- permissions
- downloads
- subscription
- restore purchase
- settings
- account
- reset/delete profile
- about/help

SYSTEM STATES

Also design:

- loading
- offline
- download progress
- no internet
- content unavailable
- failed content validation
- expired entitlement
- empty gallery
- permission denied
- error recovery

# ================================================== 28. RESPONSIVE DESIGN

Android first.

But codebase should remain cross-platform.

Support:

- common Android phones
- larger Android phones
- tablets
- eventual iPhone
- eventual iPad

Do not design only for one fixed screen.

Use responsive constraints.

Tablet experience should intelligently use available space rather than merely stretch phone UI.

# ================================================== 29. ACCESSIBILITY

Include:

- large tap targets
- scalable text where practical
- screen-reader labels for parent UI
- visual alternatives to voice
- reduced-motion support
- colour contrast
- avoid important information communicated only through colour
- captions/text for important spoken instructions when developmentally appropriate
- volume controls

# ================================================== 30. SOUND DESIGN

Implement audio architecture for:

- pet voice
- UI interaction
- room ambience
- drawing
- puzzles
- story narration
- rewards
- music

Avoid constant noisy stimulation.

Music should duck correctly during narration.

Allow parents to independently control:

- music
- sound effects
- voice

# ================================================== 31. PERFORMANCE

Optimise for mid-range Android devices.

Requirements:

- fast cold start
- no unnecessary backend calls
- memory-safe image loading
- compressed assets
- content packs loaded lazily
- smooth pet animations
- smooth drawing canvas
- no janky puzzle interaction
- good battery behaviour
- no continuous background work without justification

Use profiling when available.

# ================================================== 32. DATA MODEL

Design proper models/tables for at least:

ParentAccount
ChildProfile
PetProfile
PetState
PetMemory
WorldState
InventoryItem
OwnedItem
DrawingLesson
DrawingCreation
PuzzleDefinition
PuzzleProgress
StoryDefinition
StoryProgress
StoryChoice
Reward
Milestone
ContentPack
DownloadedPack
Entitlement
ConsentRecord
AppSettings

Use schema migrations properly.

# ================================================== 33. CONTENT AUTHORING

Design content formats so future authors do not need to edit Dart code.

Use JSON/data-driven schemas for:

- drawing lessons
- puzzles
- stories
- rewards
- dialogue
- pet suggestions
- content packs

Validate all external content before use.

Include versioning.

If practical, build simple internal developer tooling/scripts to validate content packs.

# ================================================== 34. TESTING

Do not leave testing until the end.

Implement:

- unit tests
- repository tests
- database migration tests
- pet engine tests
- memory tests
- story branching tests
- puzzle engine tests
- widget tests
- core integration tests

Test critical flows:

fresh install

onboarding

app close/reopen

offline use

pet memory persistence

drawing save

puzzle completion

story resume

parent gate

content pack download

subscription entitlement

data reset

bad network

corrupted pack

# ================================================== 35. CHILD PLAYTEST READINESS

Make the app ready for supervised real-child testing.

We should be able to observe:

- can child start without help?
- does child understand environmental navigation?
- does child engage with pet?
- does child return to pet after activity?
- does child understand drawing steps?
- does child understand puzzle objective?
- do choices make sense?
- does child show creations to parent?
- are animations too slow/fast?
- does child accidentally enter parent zone?

Do not rely only on adult assumptions.

# ================================================== 36. DEVELOPMENT ROADMAP

Follow this order unless technical reality forces a change.

STAGE 0 — FOUNDATION

- project structure
- design system
- character system
- domain architecture
- database
- content schemas
- backend schema
- safety/privacy foundations

STAGE 1 — VERTICAL SLICE

Build:

- app opening
- onboarding
- one pet
- one room
- one drawing lesson
- one puzzle
- one interactive story
- reward
- pet remembers all three
- memory item appears in world

This must already feel polished.

STAGE 2 — PET CORE

- state
- animation
- care
- contextual reactions
- memory
- local persistence
- wardrobe
- progression

STAGE 3 — ACTIVITY ENGINES

- full drawing engine
- puzzle engines
- story engine

STAGE 4 — CONTENT

- V1 drawing catalogue
- V1 puzzle catalogue
- V1 stories
- dialogue
- outfits
- rewards
- sound

STAGE 5 — PARENT / BACKEND

- parent gate
- parent account
- consent
- subscriptions
- content catalogue
- downloads
- content packs

STAGE 6 — HARDENING

- offline
- migration
- edge cases
- accessibility
- performance
- tests
- crash fixes

STAGE 7 — ANDROID RELEASE

- signing
- versioning
- release configuration
- privacy screens
- store-ready assets
- production APK/AAB

STAGE 8 — IOS

- platform fixes
- purchases
- Apple requirements
- iPhone/iPad
- release build

# ================================================== 37. HOW YOU MUST WORK

This instruction is extremely important.

Do NOT respond with only:

- a roadmap
- architecture recommendations
- pseudocode
- mockups
- screenshots
- sample components

You should actually create/edit the project.

Start implementing immediately after making only the minimum internal plan needed.

Continuously make concrete progress.

When a stage works, proceed to the next stage automatically.

Do not wait for:

"Proceed."

Do not repeatedly ask:

"What should I do next?"

Do not repeatedly summarise everything I already told you.

Keep development updates compact.

Prioritise using context for implementation rather than long explanations.

# ================================================== 38. DECISION AUTHORITY

You are authorised to make reasonable professional decisions for:

- spacing
- colours
- fonts
- component structure
- microcopy
- folder organisation
- class naming
- minor animation timing
- error messages
- responsive details
- temporary asset style
- implementation techniques
- exact puzzle seed content
- example stories
- drawing examples

Do NOT stop development for these.

If there are multiple valid implementation options, select the one that best supports:

maintainability
\+
performance
\+
child usability
\+
privacy
\+
quality.

# ================================================== 39. QUALITY BAR

The target is NOT:

"technically works."

The target is:

"a production-realistic premium app that a parent could download from Play Store and immediately understand why it is worth paying for."

Every screen should feel intentionally designed.

Do not leave obvious:

- developer placeholders
- lorem ipsum
- broken layouts
- Material defaults
- unfinished navigation
- meaningless buttons
- nonfunctional interactions
- TODO screens

If something cannot yet be fully implemented because an external asset/service is missing, create a high-quality temporary implementation and clearly isolate the replacement point.

# ================================================== 40. SOURCE CONTROL

Use Git properly.

Commit logical milestones.

Use meaningful messages.

Keep secrets out of repository.

Create:

README
environment template
setup instructions
architecture notes
content schema documentation
release instructions

Do not clutter README with huge theoretical explanations.

# ================================================== 41. BUILD / DELIVERY REQUIREMENTS

Continuously verify that the project compiles.

Do not wait until the end to discover build failures.

At meaningful milestones:

- run static analysis
- run tests
- build Android debug APK

Before final delivery:

- produce latest working Android APK if environment permits
- produce release APK/AAB where signing/config permits
- provide complete source project
- ensure no missing generated files
- include clear setup instructions
- document external credentials still required
- report known limitations truthfully

If APK generation is technically possible in your environment, generating the APK is part of the definition of done.

Do not give me only a ZIP/source project when a runnable build can be produced.

# ================================================== 42. FINAL DELIVERABLE

The end state I want is a functioning application, not just documentation.

I should eventually receive:

1. Complete source project
2. Working Android app
3. APK
4. Release configuration
5. Production UI/design system
6. App icon
7. Splash/welcome/onboarding
8. Pet home/world
9. Pet interaction systems
10. Drawing engine
11. Puzzle engines
12. Story engine
13. Memory system
14. Wardrobe/care
15. Parent zone
16. Offline persistence
17. Backend integration
18. Content pack system
19. Subscription architecture
20. Tests
21. Documentation
22. Store-preparation assets/instructions
23. Clear known limitations if any remain

# ================================================== 43. MOST IMPORTANT PRIORITY ORDER

If context, tool or execution limits ever force prioritisation, use this order:

1. Working build
2. Core architecture
3. Pet relationship experience
4. Complete navigation/flows
5. Drawing engine
6. Puzzle engine
7. Story engine
8. Memory/persistence
9. Parent/privacy
10. Backend/content delivery
11. Polish
12. Additional content quantity

Never sacrifice a functioning coherent app merely to generate hundreds of content items.

A smaller polished app is better than a giant broken one.

# ================================================== 44. FIRST ACTION

Begin now.

Do not return only a proposal.

First inspect/create the project and establish the production foundation.

Then implement the app in the roadmap order above.

The earliest milestone must be a polished vertical slice containing:

WELCOME
→ SETUP
→ MEET PET
→ PET HOME
→ DRAWING
→ PUZZLE
→ STORY
→ PET MEMORY/REWARD

Once that slice is genuinely functional, continue expanding toward the complete V1 without waiting for another instruction from me.

Throughout the build, make reasonable decisions independently, keep the project compiling, test continuously, and push toward the maximum complete runnable app your available environment can deliver.