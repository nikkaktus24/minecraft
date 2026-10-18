#!/usr/bin/env bash
# Install a local (no Docker) Minecraft 1.20.1 Forge dedicated server.
# Reuses mods/urls.txt via scripts/fetch-mods.sh. Does not commit jars.
set -euo pipefail

cd "$(dirname "$0")"
# shellcheck source=common.sh
source ./common.sh
load_local_env
if [[ "$FORGE_VERSION" != "$forge_default" ]]; then
  echo "warning: local installer is pinned to Forge ${forge_default} (not FORGE_VERSION=${FORGE_VERSION})" >&2
  FORGE_VERSION="$forge_default"
  export FORGE_VERSION
fi
require_java

installer_url="$(
  python3 - "$local_dir/installer-url.txt" <<'PY'
from pathlib import Path
import sys
for line in Path(sys.argv[1]).read_text().splitlines():
    line = line.strip()
    if line and not line.startswith("#"):
        print(line)
        break
else:
    raise SystemExit("no installer URL in local/installer-url.txt")
PY
)"

mkdir -p "$cache_dir" "$server_dir/mods"

echo "Downloading Forge installer $installer_name"
curl -fL --retry 3 --retry-delay 2 -o "$cache_dir/$installer_name" "$installer_url"
(cd "$cache_dir" && sha256sum -c "$local_dir/checksums.sha256")

echo "Installing Forge ${mc_version}-${FORGE_VERSION} into $server_dir"
cp -f "$cache_dir/$installer_name" "$server_dir/$installer_name"
(
  cd "$server_dir"
  "$JAVA_BIN" -jar "$installer_name" --installServer
)
rm -f "$server_dir/$installer_name" "$server_dir/${installer_name}.log" \
  "$server_dir/installer.log" "$server_dir/forge-${mc_version}-${FORGE_VERSION}-installer.jar.log"

args="$(unix_args_file)"
if [[ ! -f "$args" ]]; then
  echo "Forge install did not produce $args" >&2
  exit 1
fi

echo "Fetching server mods (same list as Docker MODS / mods/urls.txt)"
"$root/scripts/fetch-mods.sh" "$root/mods/jars"
shopt -s nullglob
copied=0
for jar in "$root/mods/jars/"*.jar; do
  base="$(basename "$jar")"
  if [[ "$base" == OptiFine* ]]; then
    echo "skipping client-only $base" >&2
    continue
  fi
  cp -f "$jar" "$server_dir/mods/"
  copied=$((copied + 1))
done
if [[ "$copied" -lt 1 ]]; then
  echo "no server jars copied from mods/jars" >&2
  exit 1
fi
if [[ ! -f "$server_dir/mods/serverlogin-1.0.3.jar" ]]; then
  echo "missing serverlogin-1.0.3.jar in $server_dir/mods" >&2
  exit 1
fi
if compgen -G "$server_dir/mods/OptiFine*" >/dev/null; then
  echo "OptiFine must not be installed on the dedicated server" >&2
  exit 1
fi

write_eula
write_jvm_args
upsert_server_properties

echo
echo "Local server installed in $server_dir"
echo "  Minecraft ${mc_version}  Forge ${FORGE_VERSION}  Java $($JAVA_BIN -version 2>&1 | head -n1)"
echo "  eula=true  online-mode=${ONLINE_MODE}  max-players=${MAX_PLAYERS}"
echo "  /login password (SERVER_PASSWORD): ${SERVER_PASSWORD}"
echo "Start:  $local_dir/start.sh"
echo "Stop:   $local_dir/stop.sh"
