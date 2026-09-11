# Acaciana Fub — Gate 7 playback

The accepted route is ready for a child playback session. [Start with the handoff guide](docs/gate-7.md), including the introduction, feedback questions and blank observation sheet. Child feedback and the next development decision are pending.

Gate 6 is pinned in **Test history** alongside Gates 1–5. This handoff changes no gameplay. The new archive appears after the normal manual deployment.

## Controls

- **Move:** WASD / arrows or the touch thumbpad.
- **Use / collect:** E or the on-screen USE button. A prompt appears within reach.
- **Attack after collecting the sword:** J / Space or ATTACK.
- **Gamepad:** Left stick / D-pad to move; bottom button (A) to use, left button (X) to attack, right button (B) to close, Menu/Start to restart, top button (Y) to mute. Prompts use Xbox-style labels.
- **Sound:** M, Y or the Sound button toggles sound. Preference survives Restart; page reload restores sound on. Click/tap the game once if the browser needs a gesture to enable audio or the controller.
- **Close memory:** E / Escape or Continue. **Restart:** R or Restart.

The default scene is `scenes/gate5.tscn`. The prior interaction test remains available as `scenes/gate3.tscn` and in Test history.

## Play earlier gates

The game page includes **Test history**, with browser-playable Gate 1 (movement), Gate 2 (combat) Gate 3 (interaction), Gate 4 (connected route) Gate 5 (presentation) and Gate 6 (QA). Each is rebuilt from the exact commit and Godot version recorded in `history/gates.json`; later gameplay changes do not alter that source snapshot. New gates are added to this manifest before progressing further. See [archive maintenance](docs/test-history.md).

The root URL opens the latest test with navigation. Its exported game lives at `/play/`, and historical tests live under `/history/gate-N/`. These pages are part of both the downloadable build and the existing Vercel deployment. No new secrets are needed.

## Locked foundation

Godot `4.7.2-stable`, GDScript, Compatibility renderer (`gl_compatibility`) and single-threaded Web export. *A Link to the Past* is the top-down reference; Gauntlet is the gated build process.

The default scene is `scenes/gate5.tscn`. The original movement course and pipeline smoke scene remain available independently. See [the corrected brief](docs/prototype-0.md) and [Gate 1 checks](docs/gate-1.md).

## Cloud development

Open the repository in GitHub Codespaces. The dev container installs the pinned Godot editor binary and matching export templates, then adds `godot` to `PATH`.

The Codespace is configured primarily for source editing and command-line validation/export. For full visual editing, clone the repository to a machine with the matching Godot editor.

Useful commands:

```bash
bash scripts/validate.sh
bash scripts/export-web.sh
python3 -m http.server 8000 --directory build/web
```

Open port 8000 and click the game once if it needs keyboard focus. Downloaded web builds must be served over HTTP; opening `index.html` directly from disk does not work.

To run in the matching Godot editor, open `project.godot` and press **F6** on `scenes/gate5.tscn`, or **F5** to run the project. Command line: `godot --path .`.

## GitHub Actions web build

`.github/workflows/build-web.yml` runs for pushes to `main`, pull requests, and manual dispatches. It:

1. Downloads the pinned Linux Godot editor and matching official export templates.
2. Opens/imports the project headlessly.
3. Runs the smoke scene and exercises Gate 1 movement, collisions, the complete route, camera bounds, focus loss and restart; then tests combat, interaction and the connected route, including collision, backtracking, completion and reset.
4. Exports the `Web` preset to `build/web/index.html`.
5. Opens the export in Chromium and checks rendering, keyboard and multitouch movement/attacks, combat, room traversal, switch, memory, endpoint and restart in desktop, portrait and landscape; it also checks historical gates.
6. Uploads the complete web build plus validation logs and screenshots as 14-day GitHub Actions artifacts.

To download a build, open **Actions → Validate and build web → a successful run → Artifacts**.

## Vercel setup

Deployment remains manual. In Vercel use **Framework Preset: Other** and the repository root (`./`). The supported workflow uploads a prebuilt static bundle, so Vercel does not need a Godot build command or an install command. GitHub Actions creates the web output; no credentials belong in the game or project files.

### One-time Vercel account/project setup

1. Sign in to Vercel and create an empty project for this game. Connecting the GitHub repository to Vercel is optional because GitHub Actions performs the build and deployment.
2. Create a Vercel access token under **Account Settings → Tokens**.
3. Find the Vercel team/account ID and project ID in project settings, or by running `vercel link` locally and inspecting the generated `.vercel/project.json`. Do not commit that directory.
4. In this GitHub repository, open **Settings → Secrets and variables → Actions** and add these repository secrets:

| Secret | Value |
| --- | --- |
| `VERCEL_TOKEN` | Vercel access token |
| `VERCEL_ORG_ID` | Vercel account/team ID |
| `VERCEL_PROJECT_ID` | Vercel project ID |

No Vercel value is stored in source control. `.vercel/` and all generated builds are ignored.

### Deploy

Open **Actions → Deploy web to Vercel → Run workflow**, then choose `preview` or `production`. The workflow independently validates and exports the pinned Godot project, prepares a Vercel Build Output API bundle, and deploys it.

If you also enable Vercel's GitHub integration, disable its automatic source builds to avoid duplicate deployments; this repository's supported deployment path is the manual GitHub Actions workflow.

## Scope boundary

Ross confirmed that Gauntlet is the gated development method and *A Link to the Past* supplies the top-down gameplay reference, superseding the v0.1 handoff’s side-view/jump recommendation. Gate 3 adds interaction and collection to a disposable test arena. The coherent Virginiana level, final memory text and multiplayer are outside this change. Unknown lore stays marked in the corrected brief.
