# Gate 4 — Virginiana route

Gate 3 was tested and accepted by Ross on 11 September 2026 (his feedback: “it works”), from merged revision 84deecb1b73f7d4ab6361c47122f09297126bc77 and deployment run 34505958250. The exact revision and Godot version are pinned in Test history. Gates 1 and 2 remain unchanged.

## Scope

Three connected greybox screens turn the tested mechanics into a start-to-finish route. Virginiana is the proposed starting location. The clearing names, geometry, switch and passage are provisional design choices, not story canon. Abstract shapes remain placeholders for final artwork. Memory text remains `[CANON_TBD: memory text and connection to Fred]`. No lore, gamepad, sound, save system or multiplayer is added. Gate 5 covers presentation and gamepad work.

This is a short structural test, not yet the eventual 5–10 minute slice. Timing and enjoyment need real playback before expansion.

## Play

1. In the starting clearing, collect the sword with E / USE, then defeat the red enemy with J / Space / ATTACK. Health can reach zero; Restart restores the full route.
2. Follow the east arrow to the blocked passage. Approach the gold switch and press E / USE. Walk through the opening and continue east.
3. Approach the green memory, press E / USE and read the placeholder. Close with Continue, E or Escape.
4. Approach the ring beside the memory location and press E / USE to finish.
5. Restart to reset health, inventory, enemy, switch, room and completion.

West arrows allow backtracking. Collected items do not respawn and the passage stays open until restart/reload. The enemy must be defeated before leaving the first clearing. Reading the memory or losing focus blocks room changes. Completion stops movement and attacks while leaving Restart available.

Keyboard: WASD/arrows, E interact, J/Space attack, R restart. Mobile: thumbpad, USE, ATTACK and Restart; landscape preferred. Context prompts identify the nearby action.

## Validation and acceptance

CI runs existing movement/combat/interaction tests, route checks for gated exits, actual barrier collision, switch range and focus handling, persistent backtracking, memory requirement, completion, death and reset. Chromium runs the complete current route on desktop and portrait/landscape touch emulation, then regressions for archived gates and history navigation. Logs and screenshots accompany the Actions run linked from the PR.

Gate 4 is not accepted until Ross plays it. Physical phone feel and Safari remain unverified. Playback questions: Is the route clear? Is the switch understandable? Does backtracking feel consistent? Does the endpoint read as a finish? Does restart reliably reset everything?

Before Gate 5, record actual playback acceptance and pin the merged Gate 4 revision in history.

## Acceptance recorded

Ross played the deployed route and confirmed “tesed, works” on 11 September 2026. Accepted merged revision: 16e3483c4d86c071e65b062a3340d6cea2505f53; deployment run 34597710289. This build is now pinned in Test history.
