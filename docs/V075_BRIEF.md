# Authoritative v0.7.5 execution brief

Text transcribed from the supplied DOCX. Embedded baseline screenshots remain in the original document.

MILO & ME

v0.7.5 — PREMIUM VISUAL EXPERIENCE REBUILD

Astra Medium Autonomous Design + Implementation Brief

Current working app baseline: preserve functionality; substantially elevate the visual product.

THIS IS NOT A REBUILD OF THE APP ARCHITECTURE. It is a production-level visual, character, interaction, story and content-presentation upgrade on top of the existing working Milo & Me application.

Execution principle: preserve what works → replace prototype presentation → validate every flow → ship a new APK.

1. Mission

Continue from the existing Milo & Me repository and current functional milestone. The application already has meaningful functionality, working navigation and core systems. The visual experience is now the bottleneck. Your task is to transform the existing product into a visually compelling, commercially credible premium children's experience without throwing away working systems.

The child should feel that they entered Milo's world — not that they opened a Flutter app containing cards, buttons and feature menus.

Do not restart, regenerate or replace the project wholesale.

Do not discard the working pet engine, persistence, content engines, parent systems, backend interfaces or repository history.

Commit the pre-redesign baseline before major visual changes so rollback remains possible.

Work autonomously. Do not stop for routine UI or art-direction approval.

The deliverable is the implemented working app and APK, not design commentary or mockups alone.

2. Current-State Visual Audit

The screenshots below represent a functional but prototype-level visual language. Treat them as evidence of what must improve, not as a style guide to preserve.

Onboarding: functional, but static, form-like and text-heavy.

Home: the room is a card inside an app rather than the world itself.

Dress-up: list/settings feel instead of a visual wardrobe experience.

Roleplay: placeholder geometry instead of an illustrated pretend-play scene.

Observed problems to solve:

Too many large rectangles, generic cards, labels and Material-style controls.

Milo currently reads as a simple prototype vector mascot rather than the core IP of a premium children's product.

The world is visually repetitive; different areas often feel like the same room with changed icons or props.

Art and puzzle catalogues rely heavily on coloured cards and text rather than irresistible visual covers.

Dress-up behaves like a settings list rather than a tactile wardrobe.

Roleplay screens rely on abstract shapes and placeholder props.

Stories are not immediately understandable as interactive illustrated adventures.

Visual hierarchy is weak: text, buttons, character and world compete rather than guiding attention.

Pastels are pleasant but too uniformly washed out; depth, focal contrast, lighting and richer art direction are missing.

There is insufficient delight: expressive character motion, environmental animation, transitions, tactile feedback and reward reveals.

The child experience still relies too much on reading labels instead of recognising objects and visual affordances.

3. New Quality Bar

The redesign must reach the care, polish, character appeal and environmental richness expected from leading premium children's products, while remaining unmistakably original to Milo & Me. Do not copy another app's characters, copyrighted art, exact layouts or proprietary assets.

REFERENCE PRINCIPLE: learn from the polish of premium kids products; copy none of their protected creative expression. Build an original Milo & Me identity.

The visual experience should feel:

warm

premium

whimsical

story-driven

softly dimensional

richly illustrated

tactile

emotionally inviting

modern

calm rather than overstimulating

distinctive enough to become a character brand

Avoid both extremes:

flat productivity-app minimalism

hyper-saturated, noisy, cheap mobile-game aesthetics

Use depth through layered environments, foreground/background separation, believable illustrated materials, soft lighting, carefully controlled shadows, subtle gradients, organic silhouettes, environmental detail and purposeful motion.

4. Core UX Principle — The World Is the Interface

Replace “interface containing a world” with “THE WORLD IS THE INTERFACE.”

Whenever developmentally appropriate, children should navigate by interacting with recognisable objects in Milo's environment rather than reading feature names. Text can support the experience but must not carry the primary interaction model.

Easel / paint table → Drawing

Glowing book / bookshelf → Stories

Puzzle or toy chest → Puzzles

Wardrobe → Dress Up

Memory shelf / photo wall → Memories

Bed → Rest

Care / kitchen objects → Care or Cooking

Garden elements → Nature / Science / exploration

Use subtle discoverability cues: a book glows, the toy chest wiggles once, an easel catches light, Milo looks toward a recommended activity, or a small particle trail guides attention. Do not pulse every object continuously.

5. Milo — Redesign the Core IP

Current Milo is a valid prototype but not yet strong enough to carry a long-term children's brand. Redesign Milo as a production-quality original mascot while preserving his friendly identity and recognisability where useful.

5.1 Character Requirements

Instantly recognisable silhouette at icon size.

More expressive eyes with eyelid/eyebrow control.

Readable mouth shapes for smiles, speech, surprise and emotion.

Appealing paws/hands and feet suitable for object interaction.

Improved ear construction and body proportions.

Subtle visual texture/material treatment without making the character photorealistic.

One memorable signature visual feature unique to Milo.

Expression readability even on small phones.

Outfit compatibility without requiring separate character rigs for every costume.

5.2 Expression / Pose Library

neutral

happy

laughing

excited

curious

surprised

thinking

proud

sleepy

asleep

gently worried

concentrating

celebrating

eating

drawing

reading

cooking

exploring

cuddling

waving

5.3 Idle Life

Milo must feel alive even when the child is not actively tapping him.

breathing

blink variations

ear movement

eye tracking

looking around

small stretch

tiny posture shifts

occasional interaction with a nearby room object

context-aware reactions to recent events

Animation should remain restrained. Milo must feel alive, not restless.

6. Personalisation and Dress-Up

Keep one central Milo character. Expand personalisation without exploding art/engineering complexity.

Several curated base colour themes.

Hats, glasses, scarves, accessories and themed costumes.

Outfits tied to activities where appropriate: chef → cooking, astronaut → space, detective → mystery, etc.

Immediate visual application when an item is selected.

Clear earned/locked states without purchase pressure.

Replace the current list-style dress-up screen with a real illustrated dressing-room experience: large Milo preview, wardrobe/rail/drawer visual, item thumbnails as objects, smooth equip/remove animation and clear category navigation.

7. Home and World Rebuild

The current home screen must stop feeling like a dashboard. The room should occupy most of the child experience and become the primary navigation surface.

7.1 Required Distinct Locations

Area

Visual / Functional Identity

Bedroom

Warm, cosy, soft evening lighting; bed, wardrobe, memory objects; rest and dress-up live naturally here.

Art Studio

Paper, paint, easel, hanging creations, jars, playful mess; drawing feels physical and creative.

Story Nook

Cushions, lamp, magical bookcase, layered lighting; intimate picture-book atmosphere.

Play Corner

Blocks, puzzles, toy chest, tactile floor space; more energetic but still visually calm.

Care / Kitchen

Friendly kitchen/care environment; food and care interactions use real illustrated props.

Garden

Plants, butterflies, weather, seasonal details; bridge into science and real-world exploration.

Do not reuse the same room shell and merely replace labels or icons. Every area must feel like a distinct place in one coherent visual universe.

8. Child UI Design System

Replace generic Material appearance with an original Milo & Me component language.

Use soft organic buttons, illustrated chips and tactile controls only where interface elements are genuinely needed.

Use fewer words. A child should understand the primary action even if they cannot read.

Maintain large touch targets and clear pressed/selected states.

Use hierarchy intentionally: Milo/world first, immediate interaction second, supportive text third.

Avoid large empty cards whose only purpose is holding a label.

Build a consistent spacing, radius, typography, elevation, icon and motion token system.

8.1 Icon System

Replace the mixture of generic icons and unrelated visual styles with one coherent icon family: soft-rounded, slightly illustrated, child-readable and visually consistent with the world art. Avoid mixing emoji, Material icons and custom illustrations unless intentionally designed as a system.

9. Onboarding Rebuild

Preserve the existing parent/privacy logic and data flow, but redesign the child-facing onboarding as a short story-like introduction rather than a sequence of forms.

Meet Milo quickly.

Milo progressively appears/comes alive through the onboarding sequence.

Nickname and Milo naming should feel like meeting a friend, not filling a form.

Colour/personalisation choices should be visual and immediate.

Keep grown-up privacy/consent information clear and separated into the parent step.

Reduce decorative empty space and excessive explanatory copy on child steps.

The final onboarding moment should naturally transition into the first shared activity and memory.

10. Drawing Library and Drawing Experience

Keep the existing reusable drawing engine and content architecture. Rebuild presentation and expand content quality.

Replace pastel text cards with illustrated lesson covers that communicate the subject instantly.

Add satisfying entry transitions from Art Studio into the lesson.

Watch / Draw Together / Create should be visually obvious, not hidden in text.

Guided strokes should feel alive and friendly; Milo can react to progress without interrupting.

Saved creations should appear in gallery and selected world display slots.

Expand toward 50+ guided experiences across animals, dinosaurs, vehicles, space, ocean, home objects, food, fantasy, nature and simple characters.

Do not create filler lessons just to hit a number. Quality and variety matter more than count.

11. Puzzle Visual Rebuild and Expansion

Preserve reusable puzzle domain engines. Upgrade the presentation so the same logic can live inside rich themed situations.

Matching, sorting, sequencing, spatial reasoning, logic, counting, patterns, memory, visual search and simple cause/effect can remain reusable engine types.

A dinosaur puzzle should visually happen in a dinosaur setting; an ocean puzzle in an underwater setting; a space puzzle in a space setting.

Use illustrated objects rather than abstract placeholder rectangles wherever feasible.

Provide clear visual instruction before expecting reading.

Use tactile drag/tap feedback, purposeful celebration and Milo reaction.

Expand toward 100+ levels, but avoid visually identical repetition. Use theme and interaction variety.

12. Story System — Complete Experience Rebuild

PRIORITY PROBLEM: the current story experience is not self-explanatory enough. An adult tester should immediately understand what is happening; a five-year-old should understand primarily through pictures, voice and interaction.

Stories must feel like interactive animated picture books or small adventures, not question screens or form-like sequences.

12.1 Gold-Standard Story Template

Build one story to an exceptionally high standard first and use it as the quality template for all others. Recommended template story: “Milo and the Missing Moonlight.”

Illustrated cover with title and visual premise.

Animated opening transition (book opens or scene reveals).

Full-screen or near-full-screen illustrated scene.

Narration/audio hook begins; text is supporting, not dominant.

Milo visibly reacts through pose, face and motion.

Child performs a simple interaction: tap, drag, find, arrange or reveal.

At least one meaningful visual choice changes the route, scene, dialogue, interaction or ending detail.

Adventure resolves emotionally and clearly.

Reward is revealed with high-quality animation.

A memory and/or world object persists after completion.

12.2 Story Library

Beautiful illustrated book covers instead of generic cards.

Visual new/in-progress/completed state.

Minimal metadata.

Age-appropriate duration and clear resume behaviour.

12.3 Story Scene UX

Artwork gets the majority of visual attention.

Characters physically appear in the scene where practical.

Narration and sound carry much of the storytelling.

Text is large, short and optional/supportive.

No long paragraphs for the child to read.

Choices use illustrated options, not plain text-only rectangular buttons.

12.4 Branching

Choices do not need to create dozens of endings. They need to feel meaningful. A choice can change one route, interaction, dialogue, scene detail or reward variation, then rejoin later. The child should still feel: “I chose what we did.”

12.5 Story Content Target

Expand toward 20+ high-quality stories only after the gold-standard story template is working. Every story should include a distinct visual setting, clear beginning/problem, Milo involvement, several interactions, at least one meaningful choice, emotional resolution and persistent memory/reward.

13. Roleplay and Cooking Visual Rebuild

Current roleplay screens that rely on placeholder shapes must be replaced with real illustrated pretend-play environments and recognisable objects.

Chef: visible ingredients, bowl, utensils, food transformations, Milo watching/reacting, serving and celebration.

Astronaut: cockpit/planet/space props and clear mission interactions.

Doctor: toy-care/pretend-care framing only; friendly illustrated tools and no medical claims.

Detective: clues, magnifier, objects to inspect and visual mystery progression.

Builder: blocks/materials visibly combine into something meaningful.

Artist: creative props, colour and visible creation outcome.

Cooking should use tangible visual actions: select, drag, pour, mix, arrange, decorate, transform, serve. Avoid “choose option A / choose option B” as the primary interaction when a visual action can replace it.

14. Motion and Delight System

Soft page/scene transitions.

Book opening / page turn.

Wardrobe drawer/rail motion.

Object wiggle or glow for discoverability.

Reward reveal with restrained particles/confetti where appropriate.

Environmental idle motion: light, leaves, curtains, bubbles, subtle props.

Milo emotion transitions and short contextual actions.

Respect reduced-motion settings.

Do not animate every object continuously.

Target smooth interaction and approximately 60fps on mainstream Android devices where feasible. Animation must never make drawing or puzzle input feel laggy.

15. Audio Experience

Milo voice hooks / authored voice assets.

Story narration.

Area ambience used subtly.

Music themes that do not become tiring.

Gentle interaction SFX.

Reward/celebration sound.

Music ducking during narration.

Independent parent controls for voice, music and effects.

Avoid irritating repetition. Audio should reinforce warmth, clarity and tactile feedback rather than simply make the app louder.

16. Asset Production Requirements

Do not accept primitive geometric stand-ins as final presentation if the available environment can generate or construct better original art. Use the best available visual-generation/design capabilities, then optimise assets for the app.

Milo character art and expression states.

Room/world backgrounds and layered props.

Story scene artwork and covers.

Puzzle-themed object sets and environments.

Drawing lesson covers.

Wardrobe/costume assets.

Reward/memory objects.

Onboarding illustrations.

Coherent icon set.

App icon centred on Milo's recognisable face/silhouette.

Keep source organisation clean. Assets must be individually replaceable later without rewriting domain logic. Compress and resize appropriately; do not ship oversized generated source images directly into the APK.

17. Parent UI

Parent mode may use more conventional application patterns than child mode, but it should still match the brand. It should feel calm, premium, clear and trustworthy—not childish.

privacy and consent

subscription and restore

content/download management

learning/progress summary

permissions

session/accessibility controls

profile/data reset or deletion

help/about

Do not sacrifice clarity for illustration in the parent area. The child world and parent product layer should feel related but appropriately different.

18. Content Expansion Targets

System

Target Direction

Quality Rule

Drawing

50+ guided experiences

Each cover and lesson visually distinct enough to invite choice.

Puzzles

100+ levels across reusable engines

Do not create 100 reskinned identical layouts.

Stories

20+ interactive adventures

First establish one gold-standard story; every later story must meet that bar.

Wardrobe

Broader thematic set

Items should support imagination and activity connections.

Rewards

World/memory-led

Prefer persistent visual meaning over abstract currency.

Counts are targets, not permission to generate low-quality filler. If time/context limits force a choice, prioritise polished templates, reusable visual systems and representative content over raw quantity.

19. Implementation Method

Do not finish this assignment at a Figma/mockup/specification stage. Concepts can be used internally, but implementation must happen inside the existing Flutter project.

Inspect and commit the current pre-redesign baseline.

Establish the new visual design tokens and asset pipeline.

Redesign Milo and wire the new character states into existing behaviour.

Rebuild onboarding presentation while preserving existing setup/privacy logic.

Rebuild the home/world navigation around illustrated environmental interaction.

Build distinct world areas.

Rebuild drawing library/presentation.

Rebuild puzzle presentation and thematic assets while preserving puzzle engines.

Build the gold-standard story end to end, then apply its system to the story library.

Rebuild dress-up/wardrobe.

Rebuild roleplay/cooking scenes.

Add motion/audio polish.

Expand representative content using the new visual templates.

Run a whole-app consistency pass.

Run tests and CI repeatedly; fix regressions rather than merely reporting them.

Build and expose the new Android APK artifact.

20. Preserve Functionality

VISUAL REDESIGN MUST NOT BREAK THE WORKING PRODUCT.

Inspect controllers/domain dependencies before replacing screens.

Preserve local persistence and migration compatibility unless a genuine defect requires a migration.

Preserve existing backend interfaces and child-safety rules.

Maintain offline-first behaviour.

Maintain parent-gate protection.

Maintain rewards/memories/progress behaviour.

Regression-test every major flow after visual replacement.

21. Screen-by-Screen Quality Audit

After implementation, inspect every major screen as if it were a store screenshot. For each one ask:

“Would this screenshot look at home in a top-quality paid children's app?”

If the answer is no, continue refining. Remove or fix:

placeholder art

generic developer-style components

awkward spacing

clipped or overflowed content

inconsistent iconography

excessive child-facing text

generic empty cards

visual repetition

weak hierarchy

unpolished loading/empty/error states

nonfunctional decorative controls

22. Device and Performance Validation

Common Android phone sizes, including small and tall screens.

Android tablets with layouts that adapt rather than merely stretch.

Text scaling / accessibility settings where supported.

Low/mid-range device memory behaviour.

Asset loading and cache behaviour.

Drawing responsiveness under long sessions.

Puzzle drag/tap responsiveness.

Animation jank and frame drops.

APK size impact after art expansion; use compression and lazy/downloadable assets where appropriate.

23. GitHub / CI / Delivery Rules

GitHub remains the source of truth.

Keep secrets, service keys, keystores and private credentials out of commits.

Commit logical visual/functional milestones rather than one enormous opaque commit where practical.

Run code generation if required, flutter analyze, automated tests and Android build in CI.

Do not stop after the first CI failure. Diagnose, fix, push and rerun.

Upload the Android APK as a workflow artifact.

Update concise release notes for v0.7.5.

24. Completion Gate for v0.7.5

Do not declare this milestone complete until all applicable conditions below are true:

Milo has been substantially upgraded into a production-quality mascot system.

Home feels like an explorable world rather than a dashboard/card collection.

Major world locations are visually distinct and coherent.

Onboarding is visually driven and feels like meeting a friend.

Drawing library uses compelling visual covers and retains a functional drawing flow.

Puzzles use thematic illustrated presentation rather than generic placeholder geometry.

Stories clearly function as interactive illustrated adventures with narration hooks, interactions, meaningful choices, endings and persistent rewards/memories.

Dress-up is a visual wardrobe experience with Milo large on screen.

Roleplay/cooking use recognisable illustrated scenes and props.

Motion and audio systems provide meaningful polish without overstimulation.

Child-facing design uses fewer words and more visual affordances.

Existing persistence, rewards, care, parent and offline functionality still works.

Phone/tablet overflow and clipping have been checked and fixed.

Automated checks pass and GitHub CI is green.

A new Android APK has been successfully produced and uploaded as an artifact.

25. Priority When Limits Are Tight

If execution or context limits become tight, do not waste the remaining budget on status prose or raw content quantity. Prioritise in this order:

Preserve a compiling, pushed repository.

Milo character system.

Home/world redesign.

Gold-standard story experience.

Drawing and puzzle visual templates.

Wardrobe and roleplay visual quality.

Animation/audio polish.

Representative high-quality content.

Additional content quantity.

If a hard limit is approaching, checkpoint cleanly: commit, push, keep CI green, document the exact next task in one concise note, then stop. Never leave the repository in a knowingly broken half-migrated state just to start another subsystem.

26. Start Command

BEGIN NOW. Inspect the existing Milo & Me repository and current v0.7.x implementation. Commit the current pre-redesign baseline. Then execute this Premium Visual Experience Rebuild end to end. Do not restart the project and do not stop at mockups. Preserve functionality, implement the redesigned production UI/art/interaction systems, validate the complete app, push all work to GitHub and produce the new Android APK.
