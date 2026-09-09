# Acaciana Fub — corrected Prototype 0 brief

## Approved direction (9 September 2026)

Ross confirmed both points, then asked to begin Gate 1:

- **Gauntlet** is the gated execution method in the v0.1 handoff, not Atari Gauntlet gameplay.
- **The Legend of Zelda: A Link to the Past** is the top-down gameplay reference. This replaces the handoff's Zelda II side-view recommendation and removes jump from the current prototype.

The original child-authored source remains unaltered. This records Ross's production clarification, not a rewrite of the child's story. It supersedes the view, movement and jump instructions in the handoff's README, Prototype 0 brief, Gate 1 run order and Astra master prompt. All other canon restrictions remain applicable.

## Canon / provisional / unknown

| Status | Current interpretation |
| --- | --- |
| Canon used | The player is Acaciana Fub. The proposed starting location is Virginiana. Lost memories and Fred matter to the eventual slice. |
| Confirmed production direction | Top-down 2D, GDScript, Compatibility renderer, pinned Godot 4.7.2-stable, gates followed in order. |
| Provisional | Eight-direction movement, four-direction facing, 160 world units/second, camera smoothing, circle collision body, abstract gold player marker, test-course dimensions and layout. |
| Unknown | Acaciana's final appearance, exact sword identity/appearance, enemy identity, memory wording, relationship to Fred, tree/red-seed meaning, Decaye's origin and the 12 kittens' names. |

Child scans outrank derived summaries and AI reference images. Do not invent lore to resolve gaps. The upload is the original reference; raw child scans and the secondary playback document are not reproduced in this public repository.

## Prototype 0 target

Eventually deliver a 5–10 minute original slice: gain control in Virginiana, explore, recover a basic sword, fight one enemy, complete one environmental obstacle, collect a memory fragment with a restrained Fred hint, reach an endpoint. Gate 1 is only the movement foundation, not that complete slice.

Use readable top-down spaces and responsive directional movement as reference principles. Maps, graphics, UI, names, music and code must remain original. AI reference images do not establish canon.

## Gates

| Gate | Work | Pass condition |
| --- | --- | --- |
| 0 | Inspect sources and record conflicts | Planned slice does not require invented lore; reference conflict resolved by Ross. |
| 1 | Bootable greybox, placeholder, movement, collisions, camera, restart | Course runs without errors and is traversable in both directions. |
| 2 | Sword, hit/hurt areas, one enemy, health, hit feedback | Combat is understandable and stable. |
| 3 | Interaction, pickup, memory, minimal text | Player can discover and collect a memory. |
| 4 | Coherent Virginiana start/traversal/enemy/obstacle/memory/endpoint | Small slice is playable from start to finish. |
| 5 | Lightweight original presentation, sound, transitions, gamepad | Child can operate the prototype from its prompts. |
| 6 | Route test, browser QA, logs, fixes | Blocking failures fixed; untested assumptions reported. |
| 7 | Playback handoff and observations | Ross can capture the child's reaction before planning expansion. |

## Explicit canon placeholders

- `[CANON_TBD: Acaciana's final appearance]`
- `[CANON_TBD: prototype sword identity and appearance]`
- `[CANON_TBD: enemy identity and appearance]`
- `[CANON_TBD: memory fragment wording and Acaciana's relationship to Fred]`
- `[CANON_TBD: tree and red-seed meaning]`
- `[CANON_TBD: Decaye's origin]`
- `[CANON_TBD: names of the 12 kittens]`

None of these unresolved facts is required to play Gate 1. The movement course is an abstract test environment, not a depiction of Virginiana.

## Reference links

- [Godot 4.7.2 stable](https://godotengine.org/download/archive/4.7.2-stable/)
- [Nintendo's A Link to the Past manual](https://www.nintendo.co.jp/clvs/manuals/common/pdf/CLV-P-SAAEE.pdf)
- [Godot CharacterBody2D: floating mode for top-down motion](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
