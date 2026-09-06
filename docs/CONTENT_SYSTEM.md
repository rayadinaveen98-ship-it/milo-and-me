# Content system

Authors edit versioned JSON, not Dart screens. Current included pack: `assets/content/meadow.json` (24 drawings, 55 puzzles, 12 original stories).

| Definition | Required fields | Meaning |
| --- | --- | --- |
| Pack | `schema`, `id`, `version`, `drawings`, `puzzles`, `stories` | Schema 1; positive version; bounded catalogues |
| Common activity | `id`, `title`, `topic` | Stable unique route-safe ID; child-facing title; pet-memory topic |
| Drawing | `steps` | Ordered semantic strokes |
| Drawing step | `say`, `points` | Short instruction; normalized `[x,y]` points in 0–1 |
| Puzzle | `engine`, `prompt`, `options`, `answer` | `match`, `sort`, `sequence`, `spatial` or `logic`; exact answer order |
| Story | `start`, `scenes` | Entry scene ID and scene dictionary |
| Scene | `text`, `choices` | Local narrative; empty choices means ending |
| Choice | `label`, `next` | Visible action and valid target scene ID |

Optional presentation: `subtitle`, puzzle `display`/`hint`, scene `background`/`symbol`/`emotion`. `{pet}` and `{child}` are the story substitutions. Supported backgrounds currently: space, ocean, meadow and sunset.

Drawing Watch animates guide strokes; Together displays guides beneath the child's drawing; Create omits guides. Child strokes are stored independently, with eraser, colour and width. Completion creates a thumbnail/memory visible in the room. Puzzle completion and story endings create idempotent memories and unlock cosmetics. Scene choice persistence supports resuming.

## Validation and delivery

Run `python3 tool/validate_content.py assets/content/meadow.json`. Dart `ContentEngine` validates again at runtime. Reject missing/duplicate identities, invalid coordinates, unknown engines, unsolvable options, broken branches and branches unable to end. The authoring validator also rejects unreachable scenes.

Remote packs are bounded JSON documents (currently 8 MiB), not executable scripts or extracted archives. A trusted parent catalogue supplies HTTPS URL, SHA-256, expected ID and version. Verify bytes and content before a transaction activates the pack. Reject collisions and non-increasing versions. Failed downloads must leave existing content intact.

The downloader is implemented as a repository but not exposed through a live catalogue yet. Media/voice archives, signing, premium authorization, removal and rollback require further work. `CONTENT.md` has authoring detail; `tool/make_seed.py` regenerates original seed content and intentionally overwrites manual seed edits.

## Core v0.3 additions

Optional `theme` is one of Dinosaurs/Space/Ocean/Animals/Nature. `access` labels sample/library content for future parent entitlement policy. Stories may include an `interaction` with `label`, `symbol`, `message`; choices are gated until that prop is touched, and the action persists locally. Optional `audio` is a safe bundled audio path. Content expansion is reproducible with `tool/expand_core_content.py`; it retains original IDs.
