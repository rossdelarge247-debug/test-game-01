#!/usr/bin/env bash
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.7.2}"
GODOT_RELEASE="${GODOT_RELEASE:-stable}"
GODOT_INSTALL_DIR="${GODOT_INSTALL_DIR:-${HOME}/.local/bin}"
GODOT_DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/godot"
GODOT_CACHE_DIR="${GODOT_CACHE_DIR:-${HOME}/.cache/godot/${GODOT_VERSION}-${GODOT_RELEASE}}"

if [[ "$(uname -s)" != "Linux" || "$(uname -m)" != "x86_64" ]]; then
	echo "This installer currently supports Linux x86_64 (GitHub-hosted runners and standard Codespaces)." >&2
	exit 1
fi

release_tag="${GODOT_VERSION}-${GODOT_RELEASE}"
asset_prefix="Godot_v${GODOT_VERSION}-${GODOT_RELEASE}"
download_root="https://github.com/godotengine/godot-builds/releases/download/${release_tag}"
engine_archive="${GODOT_CACHE_DIR}/${asset_prefix}_linux.x86_64.zip"
templates_archive="${GODOT_CACHE_DIR}/${asset_prefix}_export_templates.tpz"
template_dir="${GODOT_DATA_DIR}/export_templates/${GODOT_VERSION}.${GODOT_RELEASE}"

mkdir -p "${GODOT_CACHE_DIR}" "${GODOT_INSTALL_DIR}" "${template_dir}"

download() {
	local url="$1"
	local destination="$2"
	if [[ ! -s "${destination}" ]]; then
		curl --fail --location --retry 3 --retry-delay 2 "${url}" --output "${destination}"
	fi
}

download "${download_root}/$(basename "${engine_archive}")" "${engine_archive}"
download "${download_root}/$(basename "${templates_archive}")" "${templates_archive}"

temporary_dir="$(mktemp -d)"
trap 'rm -rf "${temporary_dir}"' EXIT

unzip -q -o "${engine_archive}" -d "${temporary_dir}/engine"
engine_binary="$(find "${temporary_dir}/engine" -maxdepth 1 -type f -name 'Godot*_linux.x86_64' -print -quit)"
if [[ -z "${engine_binary}" ]]; then
	echo "Godot binary was not found in ${engine_archive}." >&2
	exit 1
fi
install -m 0755 "${engine_binary}" "${GODOT_INSTALL_DIR}/godot"

unzip -q -o "${templates_archive}" -d "${temporary_dir}/templates"
cp -a "${temporary_dir}/templates/templates/." "${template_dir}/"

export PATH="${GODOT_INSTALL_DIR}:${PATH}"
installed_version="$(godot --version)"
if [[ "${installed_version}" != "${GODOT_VERSION}.${GODOT_RELEASE}"* ]]; then
	echo "Installed Godot version '${installed_version}' does not match '${GODOT_VERSION}.${GODOT_RELEASE}'." >&2
	exit 1
fi
echo "Installed Godot ${installed_version} with matching export templates."

