#!/usr/bin/env bash
# Wait for and observe the GitHub Actions run for the current commit.
# The caller owns the workflow policy; this script only maps the remote result
# to a finite command result for Funzzy.
set -euo pipefail

workflow="${GH_WORKFLOW:-on-push-nixbuild.yml}"
sha="${GH_SHA:-$(git rev-parse HEAD)}"
wait_seconds="${GH_WAIT_SECONDS:-300}"
deadline=$((SECONDS + wait_seconds))
run_id=""

while [[ -z "$run_id" ]]; do
  run_id="$(gh run list \
    --workflow "$workflow" \
    --commit "$sha" \
    --limit 1 \
    --json databaseId \
    --jq '.[0].databaseId // empty' 2>/dev/null || true)"

  if [[ -n "$run_id" ]]; then
    break
  fi

  if (( SECONDS >= deadline )); then
    echo "No $workflow run found for commit $sha after ${wait_seconds}s" >&2
    exit 1
  fi

  sleep 5
done

echo "Watching $workflow run $run_id for commit $sha"
exec gh run watch "$run_id" --compact --exit-status
