# Content system

Authors edit versioned JSON, not Dart screens. Current included pack: `assets/content/meadow.json` (24 drawings, 55 puzzles, 13 original stories).

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

v0.7.5 adds the `moonlight` illustrated background and optional normalized interaction `x`/`y` positions (0–1). `missing-moonlight` has seven short interactive scenes, two meaningful routes, seven bundled English MP3 tracks and distinct ending IDs retained in the completion memory. Catalogue featuring does not reorder stored definitions or change existing IDs. The visual renderer maps themes to original environments and symbolic puzzle objects to a 4×4 atlas; unsupported symbols retain readable text. See `assets/art/README.md` and `assets/audio/NARRATION.md` for provenance and replacement rules.

Drawing Watch animates guide strokes; Together displays guides beneath the child's drawing; Create omits guides. Child strokes are stored independently, with eraser, colour and width. Completion creates a thumbnail/memory visible in the room. Puzzle completion and story endings create idempotent memories and unlock cosmetics. Scene choice persistence supports resuming.

## Validation and delivery

Run `python3 tool/validate_content.py assets/content/meadow.json`. Dart `ContentEngine` validates again at runtime. Reject missing/duplicate identities, invalid coordinates, unknown engines, unsolvable options, broken branches and branches unable to end. The authoring validator also rejects unreachable scenes.

Remote packs are bounded JSON documents (currently 8 MiB), not executable scripts or extracted archives. A trusted parent catalogue supplies HTTPS URL, SHA-256, expected ID and version. Verify bytes and content before a transaction activates the pack. Reject collisions and non-increasing versions. Failed downloads must leave existing content intact.

Parent controls expose configured catalogue downloads, premium access and removal. Failed updates preserve the installed version. Live catalogue publication and production signing require external activation. `CONTENT.md` has authoring detail; `tool/make_seed.py` regenerates original seed content and intentionally overwrites manual seed edits.

## Core v0.3 additions

Optional `theme` is one of Dinosaurs/Space/Ocean/Animals/Nature. `access` labels sample/library content for configured parent entitlement policy. Stories may include an `interaction` with `label`, `symbol`, `message`; choices are gated until that prop is touched, and the action persists locally. Optional `audio` is a safe bundled audio path. Content expansion is reproducible with `tool/expand_core_content.py`; it retains original IDs.

## Cooking and roleplay

Optional pack arrays `cooking` and `roleplay` share identity/title/topic/theme metadata and a bounded `steps` list. Each step defines `action`, `prompt`, `symbol`, `options`, optional `repeat` (1–6) and pretend `seconds` (1–5). Accepted actions: choose/pour/mix/spread/decorate/assemble/timing/serve/prop/choice. Progress stores index, repetition count, choices and step entry time in `activities`; completion creates one idempotent memory. No real heating, cutting, ingestion or medical procedures.

Science: optional `science[]`, `safety` A/B/C, reviewed `template`, and bounded `rounds[{prompt,options,responses}]`. A renders digital cause/effect choices. B/C instructions and choices come from reviewed code templates, never downloaded prose; C requires temporary scoped parent permission. Progress is local `activities[science:id]`; completion is idempotent.

## v0.7 delivery and media

Pack JSON remains schema 1; optional `manifest` is `{schema:1,id,version,language:"en"}` and must agree with the pack. `media[]` entries contain `id`, `mime` (`image/png`, `audio/wav`, `audio/mpeg`), `bytes`, `sha256`, and base64 `data`. Limits: 8 MiB whole response, 64 assets, 2 MiB per asset, 5 MiB decoded media total, PNG dimensions at most 2048×2048. `pack:pack-id:asset-id` references supply authored audio and story `backgroundAsset`. Asset kinds and references validate before activation. Optional reward metadata lists supported outfit IDs; engines retain their established milestone rules.

The parent-owned catalogue supplies immutable HTTPS URL, expected identity/version, tier and SHA-256. Downloads reject redirects, corruption, downgrades and conflicting IDs. One SQLite transaction activates definitions plus media. Active metadata excludes media bytes; previews/narration load those lazily and recheck hashes. Invalid downloaded metadata is quarantined, with bundled fallback. Parent removal retains child memories. Reset invalidates in-flight downloads.

`access: "sample"` marks live free content; the remaining bundled library is premium in configured live builds. The default supervised playtest opens all included content. Only English packs currently activate.
