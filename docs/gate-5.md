# Gate 5 — presentation and usability

Ross accepted Gate 4 on 11 September 2026: “tesed, works”. Its merged revision 16e3483c4d86c071e65b062a3340d6cea2505f53 (deployment 34597710289) is pinned in Test history. Earlier entries remain unchanged.

## Changes

- Original code-drawn ground, paths, stone edges, switch and object labels give the three rooms distinct palettes. These are provisional presentation choices; abstract player/enemy markers and all canon placeholders remain.
- A short 0.36-second fade names the destination room. Movement, attack and interaction are suspended during the fade; focus loss pauses it. Input is cleared as it ends.
- Original synthesised PCM tones mark sword pickup, damage, enemy defeat, passage opening, room changes, memory recovery and completion. There is no music or external audio dependency.
- M, the Sound button, or gamepad Y toggles sound and immediately stops active tones. The choice survives Restart; a full page reload restores the default. Losing focus stops active cues.
- Standard gamepad mappings use the existing action system: left stick/D-pad movement with a 0.2 deadzone, bottom/A use, left/X attack, right/B close memory, Menu/Start restart, top/Y sound. Labels use Xbox conventions; physical positions describe other standard pads. Controller input selects controller prompts; keyboard and touch switch them back. Disconnect clears held movement and attack.

The route, combat tuning, inventory, obstacle, memory requirement and endpoint remain as accepted in Gate 4. No final character design, new story, multiplayer or larger map is introduced.

## Playtest

Open the latest game, click or tap once, and run the same route: sword, enemy, east exit, switch, east exit, memory, ring marker. Try sound off/on and restart. Connect a standard controller and press a button to make it visible to the browser. The popup closes with A or B; Menu restarts. Keyboard and touch remain usable.

Browser audio and controller access may require a click/tap or controller button press. The prototype uses no sound at initial boot. If a controller is unavailable, complete the keyboard/touch test and report that controller playback remains untested.

Acceptance questions: Do the paths and labels make the objective clearer? Are cues audible and comfortable? Does mute work? Are fades comfortable? Can the route and popup be operated entirely with a controller? Does unplugging the controller leave control stable?

## Verification

CI keeps prior native and archived browser regressions, adds native checks for gamepad mappings, deadzone, prompts, sound generation/mute, transitions, focus loss, popup, restart and disconnect. It runs the full presented route on desktop and portrait/landscape touch emulation, and injects a standard browser Gamepad API device to test the actual web engine input path. Screenshots and logs are uploaded with the workflow.

Generated sound data and cue triggering are checked automatically. Human listening quality, physical controller models, real-phone audio and Safari still need playback. Gate 5 is not accepted until Ross tests it. Gate 6 is the broader route/browser QA pass.

References used for implementation: [Godot controller input](https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html) and [AudioStreamWAV](https://docs.godotengine.org/en/stable/classes/class_audiostreamwav.html). Drawings and tones are implemented directly in GDScript and carry no external asset licence requirement.

## Acceptance recorded

Ross tested deployment 34606357469 and confirmed “tested, it works” on 11 September 2026. Accepted revision: 44256d08c09aa71b9f77febcae75086d2445fa84. It is now pinned in Test history. Device/browser and physical controller use were not specified.
