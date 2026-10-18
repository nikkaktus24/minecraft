#!/usr/bin/env bash
# Start the local Forge dedicated server (background by default).
# Usage: ./local/start.sh [--fg]
set -euo pipefail

cd "$(dirname "$0")"
# shellcheck source=common.sh
source ./common.sh
load_local_env
require_java

fg=0
if [[ "${1:-}" == "--fg" || "${1:-}" == "--foreground" ]]; then
  fg=1
fi

args="$(unix_args_file)"
if [[ ! -f "$args" ]]; then
  echo "Forge is not installed. Run: $local_dir/install.sh" >&2
  exit 1
fi
if [[ ! -f "$server_dir/mods/serverlogin-1.0.3.jar" ]]; then
  echo "Server mods missing. Run: $local_dir/install.sh" >&2
  exit 1
fi

if pid="$(read_pid)" && pid_is_running "$pid"; then
  echo "Already running (pid $pid). Stop with $local_dir/stop.sh" >&2
  exit 1
fi
rm -f "$pid_file"

write_eula
write_jvm_args
upsert_server_properties
mkdir -p "$server_dir/logs"

export PATH="$(dirname "$JAVA_BIN"):$PATH"

echo "Starting IC2 Forge ${mc_version}-${FORGE_VERSION} on :${SERVER_PORT}"
echo "  online-mode=${ONLINE_MODE}  max-players=${MAX_PLAYERS}  eula=true"
echo "  After join: /login ${SERVER_PASSWORD} ${SERVER_PASSWORD}  (later: /login ${SERVER_PASSWORD})"

cd "$server_dir"
forge_args="libraries/net/minecraftforge/forge/${mc_version}-${FORGE_VERSION}/unix_args.txt"
# Same as the installer run.sh, with exec/nohup so stop.sh can signal Java.
set -- "$JAVA_BIN" "@user_jvm_args.txt" "@${forge_args}" nogui

if [[ "$fg" -eq 1 ]]; then
  exec "$@"
fi

nohup "$@" >>"$server_dir/logs/console.log" 2>&1 &
echo $! >"$pid_file"
echo "pid $(cat "$pid_file")  log $server_dir/logs/console.log"
echo "Stop: $local_dir/stop.sh"
