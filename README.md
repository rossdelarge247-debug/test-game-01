# Godot cloud game scaffold

A deliberately minimal Godot project for validating cloud development, CI, web export, and Vercel deployment before gameplay work begins.

## Locked foundation

- Godot `4.7.2-stable`
- GDScript
- Compatibility renderer (`gl_compatibility`)
- Single-threaded Web export for broad hosting/browser compatibility
- No gameplay, input model, networking, persistence, or multiplayer architecture yet

The only scene is `scenes/smoke_test.tscn`. It displays the runtime version and prints `SMOKE_TEST_READY` so CI can prove that the project imports and starts.

## Cloud development

Open the repository in GitHub Codespaces. The dev container installs the pinned Godot editor binary and matching export templates, then adds `godot` to `PATH`.

The Codespace is configured primarily for source editing and command-line validation/export. For full visual editing, clone the repository to a machine with the matching Godot editor.

Useful commands:

```bash
bash scripts/validate.sh
bash scripts/export-web.sh
python3 -m http.server 8000 --directory build/web
```

Open port 8000 to verify the exported smoke-test scene in a browser.

## GitHub Actions web build

`.github/workflows/build-web.yml` runs for pushes to `main`, pull requests, and manual dispatches. It:

1. Downloads the pinned Linux Godot editor and matching official export templates.
2. Opens/imports the project headlessly.
3. Runs the smoke-test scene and checks for its ready signal.
4. Exports the `Web` preset to `build/web/index.html`.
5. Uploads the complete web build as a 14-day GitHub Actions artifact.

To download a build, open **Actions → Validate and build web → a successful run → Artifacts**.

## Vercel setup

Deployment is intentionally manual until the external account is connected and the smoke build is accepted.

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

The eventual direction is Gauntlet-style, but this scaffold makes no gameplay or multiplayer architecture choices. Those decisions start only after the game brief is supplied.

