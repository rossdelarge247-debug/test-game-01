# Gate 1 — movement greybox

## Run and controls

Open `project.godot` in Godot 4.7.2-stable and press F5, or run `godot --path .`. In a Codespace, use the commands in the root README to export and serve the web build. The GitHub Actions run provides the downloadable `web-build-*` artifact; extract it and serve its directory with `python3 -m http.server 8000`.

| Action | Control |
| --- | --- |
| Move in eight directions | WASD or arrow keys; combine keys for diagonals |
| Restart course | R or Restart button |
| Restore browser keyboard focus | Click inside the game |
| Move on a phone/tablet | Drag the on-screen thumb pad; lift your finger to stop |
| Restart on a phone/tablet | Tap the large Restart button |

Touch controls appear automatically on touch-capable devices. A software keyboard is not needed. Portrait works; landscape gives the course and controls more room. The pad follows its first finger even outside its ring, releases on touch cancellation or focus loss, and permits another finger to use Restart.

Follow the line through the central passage to the far ring, then return. The ring is a test landmark, not an interaction or quest endpoint. Walk into walls and around the rectangular blocks. Restart resets the scene, spawn, camera and facing. Focus loss clears held movement to prevent drifting when returning to the window.

## Structure

| File | Responsibility |
| --- | --- |
| `scenes/gate1.tscn` | Main course, player placement, landmarks and fixed HUD |
| `src/gate1.gd` | Course geometry, matching wall colliders and restart |
| `scenes/player.tscn` | CharacterBody2D, collision shape and bounded camera |
| `src/player.gd` | Input, movement, facing, focus handling and placeholder drawing |
| `scenes/smoke_test.tscn` | Original isolated boot check |
| `tests/gate1_test.gd` | Actual scene/input/physics integration checks |
| `tests/web_smoke.mjs` | Chromium export boot, rendering, movement and restart checks |
| `scripts/validate.sh` | Import, boot, error-log checks and Gate 1 integration runner |

## Automated evidence

CI runs `scripts/validate.sh`, exports with the matching Godot templates, then opens the release export in Chromium. The movement runner checks the configured keys, diagonal speed, immediate stopping, all outer boundaries, partition walls, an obstacle corner, the complete outbound/return route, camera clamping, focus clearing and both restart paths.

Browser checks use keyboard events and compare the rendered course before movement and after restart. They save screenshots and a console log. Download `gate1-validation-*` from the same Actions run for evidence. A Gate 1 pass requires the current change's run to finish successfully; source inspection alone is not a runtime pass.

## Limits and next gate

This is a movement greybox. The visuals and course are provisional. Keyboard and touch movement are checked in Chromium, including emulated mobile portrait/landscape layouts. Actual phone hardware, gamepad and Safari/Firefox coverage remain unverified. Responsiveness and camera comfort still need Ross's hands-on assessment.

Combat, health, enemies, interaction, memory text and the Virginiana slice belong to later gates. No multiplayer, inventory, saving or world architecture has been introduced. All remaining canon placeholders are listed in `prototype-0.md`; no new story claims appear in the course.

## Five playback observations

1. Can the player identify Acaciana's marker and start moving from the on-screen instructions?
2. Does movement stop where expected, including when moving diagonally?
3. Can the player pass between the walls and round blocks without frustrating snags?
4. Does the camera make the next part of the route clear and stay comfortable?
5. Can the player find the far marker, return and restart without help?
