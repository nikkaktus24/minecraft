#!/usr/bin/env bash
# Fetch client mods (IC2 pack + OptiFine) into client/mods/ and verify sha256.
# Re-run anytime to refresh. Does not install Forge or copy into .minecraft.
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
dest="${1:-"$root/mods"}"
urls_file="${URLS_FILE:-"$root/urls.txt"}"
sums_file="${SUMS_FILE:-"$root/checksums.sha256"}"
user_agent="${CURL_USER_AGENT:-Mozilla/5.0}"

mkdir -p "$dest"

if [[ ! -f "$urls_file" ]]; then
  echo "missing URL list: $urls_file" >&2
  exit 1
fi
if [[ ! -f "$sums_file" ]]; then
  echo "missing checksums: $sums_file" >&2
  exit 1
fi

fetch_optifine() {
  local out="$1"
  local filename="$2"
  local page path
  echo "  $filename (optifine.net)"
  page="$(curl -fsSL -A "$user_agent" "https://optifine.net/adloadx?f=${filename}")"
  path="$(printf '%s\n' "$page" | grep -oE "downloadx\\?f=${filename}&x=[0-9a-f]+" | head -n1 || true)"
  if [[ -z "$path" ]]; then
    echo "could not parse OptiFine download link from optifine.net" >&2
    echo "Download ${filename} from https://optifine.net/downloads and save it as:" >&2
    echo "  $out" >&2
    exit 1
  fi
  curl -fL --retry 3 --retry-delay 2 -A "$user_agent" -o "$out" "https://optifine.net/${path}"
}

echo "Downloading client mods into $dest"
n=0
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%$'\r'}"
  [[ -z "$line" || "$line" == \#* ]] && continue
  n=$((n + 1))
  if [[ "$line" == optifine:* ]]; then
    file="${line#optifine:}"
    fetch_optifine "$dest/$file" "$file"
  else
    file="$(python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1].rsplit("/", 1)[-1].split("?", 1)[0]))' "$line")"
    echo "  $n. $file"
    curl -fL --retry 3 --retry-delay 2 -o "$dest/$file" "$line"
  fi
done < "$urls_file"

echo "Verifying sha256"
(cd "$dest" && sha256sum -c "$sums_file")
echo "OK — copy into your Forge mods folder with:"
echo "  $root/install-mods.sh"
echo "or:  $root/install-mods.sh /path/to/.minecraft/mods"
