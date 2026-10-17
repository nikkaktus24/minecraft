#!/usr/bin/env bash
# Copy fetched client jars into a Minecraft mods folder.
# Default: $MINECRAFT_MODS or ~/.minecraft/mods
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
src="${CLIENT_MODS_SRC:-"$root/mods"}"
dest="${1:-${MINECRAFT_MODS:-"$HOME/.minecraft/mods"}}"

if ! compgen -G "$src"/*.jar >/dev/null; then
  echo "no jars in $src — run $root/fetch-mods.sh first" >&2
  exit 1
fi

mkdir -p "$dest"
echo "Installing client mods into $dest"
cp -f "$src"/*.jar "$dest/"
echo "Installed:"
ls -1 "$dest"/*.jar | xargs -n1 basename
echo
echo "Launch Minecraft 1.20.1 with the Forge 47.4.20 profile."
echo "OptiFine is client-only; do not copy it onto the dedicated server."
