#!/usr/bin/env bash
# Download the pinned 1.20.1 Forge mod jars and verify sha256.
# Does not install Minecraft/Forge. Jars are written to mods/jars/ (gitignored).
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
dest="${1:-"$root/mods/jars"}"
urls_file="${URLS_FILE:-"$root/mods/urls.txt"}"
sums_file="${SUMS_FILE:-"$root/mods/checksums.sha256"}"

mkdir -p "$dest"

if [[ ! -f "$urls_file" ]]; then
  echo "missing URL list: $urls_file" >&2
  exit 1
fi
if [[ ! -f "$sums_file" ]]; then
  echo "missing checksums: $sums_file" >&2
  exit 1
fi

echo "Downloading mods into $dest"
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%$'\r'}"
  [[ -z "$line" || "$line" == \#* ]] && continue
  url="$line"
  file="$(basename "${url%%\?*}")"
  echo "  $file"
  curl -fL --retry 3 --retry-delay 2 -o "$dest/$file" "$url"
done < "$urls_file"

echo "Verifying sha256"
(cd "$dest" && sha256sum -c "$sums_file")
echo "OK"
