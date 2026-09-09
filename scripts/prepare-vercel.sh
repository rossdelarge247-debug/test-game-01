#!/usr/bin/env bash
set -euo pipefail

if [[ ! -s build/web/index.html ]]; then
	echo "build/web/index.html is missing. Run: bash scripts/export-web.sh" >&2
	exit 1
fi

rm -rf .vercel/output
mkdir -p .vercel/output/static
cp -a build/web/. .vercel/output/static/
printf '{"version":3}\n' > .vercel/output/config.json

echo "Prepared Vercel Build Output API bundle in .vercel/output."

