# Authoring content

Edit `assets/content/meadow.json`; authors do not need Dart. `tool/make_seed.py` recreates the original pack and will overwrite manual changes, so use it only when intentionally regenerating the starter content.

Each pack has `schema: 1`, a unique `id`, positive integer `version`, `title`, and three lists: `drawings`, `puzzles`, `stories`. Use short lowercase IDs with hyphens/underscores. IDs must be unique across installed catalogues. Every activity has `id`, `title`, `topic` and optional `subtitle`.

Drawing lessons contain `steps`. Every step has a short authored `say` instruction and `points`, an ordered list of normalized `[x,y]` coordinates from 0 to 1. One step corresponds to one semantic stroke. Repeat a starting point to close a loop. The renderer scales the normalized drawing to phones and tablets. Watch animates the guide; Together displays it beneath the child’s work; Create omits it.

Puzzles declare `engine` (`match`, `sort`, `sequence`, `spatial`, `logic`), `prompt`, `options`, `answer`, optional `display`, and gentle `hint`. Single-item answers use selection; multiple-item answers use ordered slots. Duplicate answers are allowed when a bridge or pattern requires repeated pieces. Every correct item must exist in the options. Never use shaming failure text.

Stories declare `start` and a `scenes` dictionary. Each scene has authored `text`, a supported `background` (`space`, `ocean`, `meadow`, `sunset`), optional `symbol`/`emotion`, and `choices`. Choices contain `label` and `next`. An empty choice list is an ending. `{pet}` and `{child}` are the only substitutions used by this player. Every reachable branch must be able to reach an ending; the authoring validator also rejects unreachable scenes.

Run:

```bash
python3 tool/validate_content.py assets/content/meadow.json
```

A remote pack is one JSON file, currently limited to 8 MiB. A future trusted catalogue supplies its HTTPS URL, SHA-256, expected ID and expected version. No scripts, HTML, external images or archive paths are executed by a pack. Media archives and authored voice bundles need an extended schema and new validation before activation.

Authoring acceptance: the child should have a meaningful choice, understand the objective with minimal reading, receive gentle feedback, and create a memory that belongs in the pet’s world. Stories here are original imaginative fiction; physical science claims and offline experiments require editorial review before a future science pack.
