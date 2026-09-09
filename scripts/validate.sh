#!/usr/bin/env bash
set -euo pipefail

command -v godot >/dev/null 2>&1 || {
	echo "godot is not on PATH. Run: bash scripts/install-godot.sh" >&2
	exit 1
}

echo "Importing resources and checking the project in headless editor mode…"
godot --headless --path . --editor --quit

echo "Starting the smoke-test scene for three frames…"
smoke_output="$(godot --headless --path . --quit-after 3 2>&1)"
printf '%s\n' "${smoke_output}"
grep -q "SMOKE_TEST_READY" <<<"${smoke_output}"

echo "Project validation passed."

