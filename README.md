# Acaciana Fub — Prototype 0

An original top-down action-adventure prototype, developed through the handoff’s Gauntlet gates. Gate 1 adds a playable movement greybox to the existing cloud build pipeline.

## Locked foundation

- Godot `4.7.2-stable`
- GDScript
- Compatibility renderer (`gl_compatibility`)
- Single-threaded Web export for broad hosting/browser compatibility
- Gate 1 only: movement, facing, walls, camera and restart
- Gameplay reference: *A Link to the Past*; Gauntlet describes the build process

The default scene is `scenes/gate1.tscn`. Move with **WASD or arrow keys**; restart with **R or the on-screen button**. Follow the line through the passage and walk back. The gold marker is Acaciana’s temporary placeholder.

The original `scenes/smoke_test.tscn` remains as a separate pipeline check. See [the corrected brief](docs/prototype-0.md) and [Gate 1 checks and playback guide](docs/gate-1.md).

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

To run in the matching Godot editor, open `project.godot` and press **F6** on `scenes/gate1.tscn`, or **F5** to run the project. Command line: `godot --path .`.

## GitHub Actions web build

`.github/workflows/build-web.yml` runs for pushes to `main`, pull requests, and manual dispatches. It:

1. Downloads the pinned Linux Godot editor and matching official export templates.
2. Opens/imports the project headlessly.
3. Runs the smoke scene and exercises Gate 1 movement, collisions, the complete route, camera bounds, focus loss and restart.
4. Exports the `Web` preset to `build/web/index.html`.
5. Opens the export in Chromium and checks rendering, keyboard input and restart.
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

Ross confirmed that Gauntlet is the gated development method and *A Link to the Past* supplies the top-down gameplay reference, superseding the v0.1 handoff’s side-view/jump recommendation. Gate 1 is a disposable movement course; combat, story scenes, interactions and multiplayer are outside this change. Unknown lore stays marked in the corrected brief.

