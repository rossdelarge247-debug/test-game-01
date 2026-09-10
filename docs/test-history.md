# Playable test history

Ross requested a way to see the game's evolution after testing Gate 2. The root game page now has a Test history link. Gate 1 and Gate 2 have permanent, distinct routes within every subsequent web build:

- `/history/gate-1/`: the movement course with mobile controls.
- `/history/gate-2/`: the combat arena with health and touch attacks.
- `/`: the latest test, with navigation; its game assets are at `/play/`.

## What is frozen

`history/gates.json` records full commit SHAs, engine versions and release channels. Each archive is exported from a separate temporary checkout of that exact commit, with its original main scene and resources. Changing today's player script or main scene does not alter a historical snapshot. History is rebuilt and included with every deployment, so it does not depend on expiring Actions artifacts or an old Vercel deployment staying available.

This preserves the source and engine revision; it is not a claim of byte-identical builds or identical behaviour in future browsers. `provenance.json` beside each historical player records its source revision, engine and exported pack hash. Original code remains in git history. Do not rewrite that history or move the recorded snapshots to newer code.

## At each new gate

1. Before progressing, ensure the tested version of the completed gate has an entry in `history/gates.json`. Use a full merged commit SHA and the exact engine/template version.
2. Keep previous entries unchanged. If a later fix is worth preserving, give it a new archive entry rather than silently replacing the old snapshot.
3. Update `current_title` for the next test. Add its frozen entry after testing and merging it, before starting another gate.
4. Keep the entry's `ready_marker` consistent with that snapshot's scene log. The archive browser test uses it to verify the correct old scene starts.

Both Actions workflows check out full git history. `export-web.sh` exports the current game and then invokes `build-history.py`. The history builder installs an older matching stable engine into an isolated temporary tools directory when required; it leaves the current engine in place. It imports and exports each old project, checks errors and assets, then builds static navigation pages. Vercel preparation copies the complete output recursively. No added credentials, account connections or services are required.

For local builds, use a full git checkout, Python 3.12+ and the existing Linux Godot installer. A shallow clone needs `git fetch --unshallow` first. Archived sources live outside the current project during export to avoid recursive imports. The resulting `build/web` directory remains downloadable and can be served over HTTP as before.

CI tests the latest combat inside the new navigation shell on desktop and both mobile orientations. It also follows history links, boots each pinned scene, moves its player and returns to the history page. Archive size/build time will grow with the number of gates; keeping exact old versions is preferred over sharing mutable gameplay resources.
