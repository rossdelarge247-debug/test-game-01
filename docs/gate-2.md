# Gate 2 — combat feel

Gate 1 was accepted by Ross on 10 September 2026 after testing mobile controls.
Gate 2 remains proposed until Ross tests and accepts combat.

## Scope and controls

One abstract top-down arena, Acaciana's existing gold placeholder, one red diamond enemy, sword hit area, enemy/player hurt areas, health, damage protection, knockback, clear defeat and restart. Keyboard: WASD/arrows, J/Space to attack, R to restart. Touch: drag the left pad, hold ATTACK with a second finger, lift to stop; Restart is above Attack. Landscape gives more room. Holding attack repeats swings at the cooldown rate.

The sword/enemy identity and appearance are `[CANON_TBD]`. Neither shape is final art. No pickups, sword acquisition story, memory text, multiplayer or new lore is introduced. This arena is not Virginiana.

## Provisional tuning

| Parameter | Value |
| --- | --- |
| Player / enemy speed | 160 / 48 units per second |
| Player / enemy health | 5 / 3 |
| Sword / contact damage | 1 / 1 |
| Sword active time / repeat cooldown | 0.16 / 0.34 seconds |
| Protection after damage | 0.9 seconds |
| Enemy hit stun | 0.25 seconds |
| Pursuit activation range | 110 units; pursuit continues once activated |

Movement remains eight-way with cardinal facing. Each swing locks its direction, reaches 44 units forward and can damage a given target once. A physics ray against walls blocks hits through cover. Hits flash the enemy white and knock it back; player damage shows a pink protection ring and updates health. Victory stops combat; defeat stops both actors. Restart recreates health, actors and input state. Focus loss clears movement and attack and suspends damage/pursuit.

The original Gate 1 scene and movement checks remain available. The Gate 2 player extends that movement implementation. Hurtboxes and contact areas use named physics layers; sword queries run in physics time against its scene-defined shape.

## Review checklist

1. Approach the red diamond, face it and swing. Is direction/range understandable?
2. Defeat it with three hits. Can you distinguish a hit from a miss?
3. Let it touch you. Does losing health and brief protection make sense?
4. Lose all five health points, then restart. Repeat after winning.
5. On a phone, move and attack together, lift both fingers, then switch away and back. Check that movement/attacks do not stick.

GitHub Actions runs the existing movement suite plus combat integration checks, exports with matching Godot templates, and tests the normal exported game in desktop Chromium and portrait/landscape touch emulation. Review the run linked in the pull request for results and screenshots. Actual Android/iOS combat feel, Safari and physical gamepads are untested. There is no navigation/pathfinding: the one pursuer collides with the small wall and may need luring around it.

## Run and deploy

The default project scene is `scenes/gate2.tscn`. The manual Deploy web to Vercel workflow can build this branch as a preview for review, or main as production after merging. Existing Vercel secrets are used; no new account connections or secrets are needed. See the root deployment documentation. Gate 3 starts only after this gate is accepted.
