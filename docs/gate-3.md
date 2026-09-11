# Gate 3 — interaction and collection

Ross reported Gate 2 working, then tested and confirmed the playable Test history. Gates 1 and 2 remain pinned in `history/gates.json`. Ross tested the deployed Gate 3 sequence and confirmed it works on 11 September 2026. Accepted revision: 84deecb1b73f7d4ab6361c47122f09297126bc77; deployment run 34505958250. This revision is now pinned in playable history.

## Play the test

1. Move slightly right toward the sword symbol. The footer changes to Collect sword when within reach.
2. Press E or tap USE. The item disappears, the sword counter changes to 1/1 and attacks become available.
3. Defeat the red enemy using J/Space or ATTACK. Movement remains available after victory, and a green memory fragment appears.
4. Approach the fragment and press E / USE. The counter changes to 1/1 and a memory popup opens.
5. Close with Continue, E or Escape. Restart to repeat the test from an empty inventory and full health.

Touch controls support moving and attacking together. USE is a distinct press rather than a repeating held action. Landscape gives more room. The Attack button appears after sword acquisition. While the popup is open, movement, attacks, damage and enemy motion stop; closing it releases held input so it cannot cause a surprise movement or attack.

## Scope and canon

This remains an abstract room. Using the sword to defeat one enemy before a memory becomes available is provisional test sequencing. It does not establish a magical cause, final quest order, item identity, enemy identity or location. The memory text is exactly:

`[CANON_TBD: memory text and connection to Fred]`

No relationship to Fred or remembered event is invented. Gate 4 will make a coherent Virginiana slice after this interaction gate is accepted. There is no inventory screen, save/load, dialogue tree or additional lore. Collection state is intentionally reset on restart/page reload.

## Implementation and checks

The reusable pickup area exposes a sword/memory kind, availability and single-use collection. Activation checks a 36-unit centre distance, an overlapping player body and an unobstructed line to the item. The nearest eligible item gets the context prompt. Hidden, collected or unreachable items cannot be activated. Death and focus loss block collection. The combat player defaults to equipped for the existing Gate 2 scene; Gate 3 explicitly starts unequipped.

CI runs the existing movement/combat suites, new interaction integration checks, complete Gate 3 browser routes on desktop and portrait/landscape touch emulation, archived combat browser regressions and Test history navigation. See the pull request for the final run and screenshots. Actual phone interaction/popup feel, Safari and physical gamepads require separate playback.

## Acceptance questions

- Is it clear when an object can be used and what E / USE will do?
- Does the sword pickup clearly enable attacking?
- Can you discover the memory after the enemy is defeated?
- Is the memory popup readable, and does closing it restore control cleanly?
- Does restart reliably restore sword, enemy, memory and health?

Before Gate 4, pin the tested and merged Gate 3 revision in history without changing the earlier entries, following `docs/test-history.md`.
