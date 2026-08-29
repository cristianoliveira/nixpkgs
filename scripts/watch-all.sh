#!/usr/bin/env bash
# Run the local edit loop and the finite GitHub CI observation together.
# A failed remote CI run stops the local watcher and fails this supervisor.
set -u

local_pid=""
cleanup() {
  if [[ -n "$local_pid" ]] && kill -0 "$local_pid" 2>/dev/null; then
    # Stop the watcher without making CI failure wait on a child command.
    pkill -TERM -P "$local_pid" 2>/dev/null || true
    kill "$local_pid" 2>/dev/null || true
    for _ in {1..20}; do
      kill -0 "$local_pid" 2>/dev/null || return 0
      sleep 0.1
    done
    kill -KILL "$local_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

fzz watch -c .watch.yaml &
local_pid=$!

set +e
fzz run -c .watch.yaml @ci
ci_status=$?
set -e

if (( ci_status != 0 )); then
  echo "GitHub CI failed; stopping the local Funzzy watcher" >&2
  exit "$ci_status"
fi

wait "$local_pid"
