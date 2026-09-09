#!/usr/bin/env bash
set -euo pipefail

command -v godot >/dev/null 2>&1 || {
	echo "godot is not on PATH. Run: bash scripts/install-godot.sh" >&2
	exit 1
}

rm -rf build/web
mkdir -p build/web
godot --headless --path . --export-release Web build/web/index.html

required_files=(build/web/index.html build/web/index.js build/web/index.wasm build/web/index.pck)
for required_file in "${required_files[@]}"; do
	if [[ ! -s "${required_file}" ]]; then
		echo "Expected export output is missing: ${required_file}" >&2
		exit 1
	fi
done

echo "Web export created in build/web."

