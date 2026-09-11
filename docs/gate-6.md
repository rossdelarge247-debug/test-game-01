# Gate 6 — route and browser QA

Ross accepted Gate 5 after testing deployment 34606357469: “tested, it works”. Its merged revision 44256d08c09aa71b9f77febcae75086d2445fa84 is pinned in Test history. Device/browser and physical gamepad use were not specified. Earlier pins remain unchanged.

## Scope and fixes

This gate keeps the accepted Gate 5 route and presentation. The latest scene is still scenes/gate5.tscn; the site labels the current build Gate 6 · QA. There is no additional gameplay, story or art work.

Two control risks found during review receive targeted fixes:

- Gamepad actions now match any device slot instead of slot zero only, so a controller assigned another slot can operate the game. Tests use slot 2 for actual button and axis input, including a complete browser gamepad route.
- Viewport size changes release held gameplay actions and captured touch input. This covers browser resizing/rotation even when the thumbpad's logical dimensions do not change. A browser test rotates while holding movement and checks that a fresh touch works afterward.

## Validation plan and evidence

The PR links the actual completed Actions run and results. CI runs all existing native tests and adds checks for controller slot 2, resize release, restart during each half of a fade, active-enemy focus pause/resume, death/restart, restart during the memory popup, mute persistence and backtracking through fades.

Browser coverage includes the existing full desktop and portrait/landscape Chromium routes, the slot-2 gamepad route and disconnect, all five history entries, plus a mobile sequence covering held-touch rotation, new touch input, death, restart, sound-button use and history navigation. Firefox runs the full keyboard presentation route under a virtual display with software graphics. It remains a required CI check; failures are investigated and documented rather than silently skipped.

Logs and screenshots are Actions artifacts retained for 14 days. Each historical build also carries its pinned source/engine provenance. The PR records the verified revision and results.

## Known limits

- Chromium touch/gamepad emulation does not prove physical-phone, Bluetooth or USB controller compatibility.
- Firefox uses a Linux virtual display/software rendering; this does not establish every OS/GPU combination.
- Safari/iOS WebKit and physical gamepad playback are unverified.
- Automated checks validate sound data and trigger paths; human sound comfort and hardware output require listening.
- The route remains short and provisional, with abstract characters and explicit CANON_TBD memory text. The eventual 5–10 minute slice and final art/story are not implied complete.
- This gate is implementation/QA, not Ross's acceptance or the child's playback.

## Ross's regression check after deployment

Run the familiar route once. On mobile, rotate during movement, release and try moving again. Let the enemy defeat you and restart. Test the Sound button. If available, reconnect a controller and try its movement/use actions. Confirm Test history lists Gates 1–5 and opens Gate 5. Report device/browser and any failure point.

After Ross accepts Gate 6, Gate 7 prepares the playback handoff and observation capture before planning expansion.
