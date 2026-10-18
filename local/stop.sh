#!/usr/bin/env bash
# Stop the local Forge dedicated server started by local/start.sh.
set -euo pipefail

cd "$(dirname "$0")"
# shellcheck source=common.sh
source ./common.sh
load_local_env

if ! pid="$(read_pid)"; then
  echo "Not running (no $pid_file)."
  exit 0
fi
if ! pid_is_running "$pid"; then
  echo "Not running (stale pid $pid)."
  rm -f "$pid_file"
  exit 0
fi

echo "Stopping pid $pid (SIGTERM, up to 60s)…"
kill -TERM "$pid" 2>/dev/null || true
for _ in $(seq 1 60); do
  if ! pid_is_running "$pid"; then
    rm -f "$pid_file"
    echo "Stopped."
    exit 0
  fi
  sleep 1
done
echo "Still running; sending SIGKILL."
kill -KILL "$pid" 2>/dev/null || true
rm -f "$pid_file"
echo "Stopped."
