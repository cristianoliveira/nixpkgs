#!/usr/bin/env bash
set -euo pipefail

PKGS_DIR="${PKGS_DIR:-pkgs}"
GITHUB_API_BASE="${GITHUB_API_BASE:-https://api.github.com/repos}"
FORMAT="${FORMAT:-table}"
PACKAGES=()

usage() {
  cat <<'EOF'
Usage: ./scripts/check-release-updates.sh [options]

Check packages with pkgs/<name>/update.sh for newer GitHub releases.

Options:
  --format <table|tsv|json>  Output format. Default: table
  --package <name>           Limit to one package. Repeatable.
  -h, --help                 Show help

Environment:
  PKGS_DIR         Package directory to scan. Default: pkgs
  GITHUB_API_BASE  GitHub repos API base. Default: https://api.github.com/repos
EOF
}

require_cmds() {
  local missing=()
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done

  if ((${#missing[@]} > 0)); then
    echo "error: missing required commands: ${missing[*]}" >&2
    exit 1
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --format)
        FORMAT="$2"
        shift 2
        ;;
      --package)
        PACKAGES+=("$2")
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "error: unknown option: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done
}

normalize_tag() {
  local tag="$1"
  tag="${tag#v}"
  if [[ "$tag" =~ ^[0-9] ]]; then
    echo "$tag"
    return 0
  fi

  if [[ "$tag" =~ v([0-9][0-9A-Za-z._-]*)$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi

  echo "$tag"
}

read_repo() {
  local file="$1"
  awk -F'"' '/repo="/ { print $2; exit }' "$file"
}

read_version() {
  local file="$1"
  sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$file" | head -n1
}

fetch_latest_tag() {
  local repo="$1"

  if [[ "$GITHUB_API_BASE" == "https://api.github.com/repos" ]] && command -v gh >/dev/null 2>&1; then
    gh api "repos/${repo}/releases/latest" --jq '.tag_name'
    return 0
  fi

  curl -fsSL \
    -H 'Accept: application/vnd.github+json' \
    -H 'User-Agent: nixpkgs-update-checker' \
    "${GITHUB_API_BASE}/${repo}/releases/latest" | jq -r '.tag_name'
}

collect_packages() {
  if ((${#PACKAGES[@]} > 0)); then
    printf '%s\n' "${PACKAGES[@]}"
    return 0
  fi

  find "$PKGS_DIR" -mindepth 2 -maxdepth 2 -name update.sh -print \
    | sort \
    | while read -r path; do
        basename "$(dirname "$path")"
      done
}

print_table() {
  printf '%-20s %-12s %-18s %-8s %s\n' package current latest status repo
  printf '%-20s %-12s %-18s %-8s %s\n' '-------' '-------' '------' '------' '----'
  while IFS=$'\t' read -r package current latest status repo raw_tag; do
    printf '%-20s %-12s %-18s %-8s %s\n' "$package" "$current" "$latest" "$status" "$repo"
  done
}

main() {
  require_cmds jq find sort awk sed
  parse_args "$@"

  local rows=()
  local package
  while read -r package; do
    [[ -n "$package" ]] || continue

    local update_file="$PKGS_DIR/$package/update.sh"
    local default_file="$PKGS_DIR/$package/default.nix"

    if [[ ! -f "$update_file" || ! -f "$default_file" ]]; then
      echo "warning: skipping $package: missing update.sh or default.nix" >&2
      continue
    fi

    local repo current raw_tag latest status
    repo="$(read_repo "$update_file")"
    current="$(read_version "$default_file")"

    if [[ -z "$repo" || -z "$current" ]]; then
      echo "warning: skipping $package: could not parse repo or version" >&2
      continue
    fi

    if ! raw_tag="$(fetch_latest_tag "$repo" 2>/dev/null)"; then
      rows+=("$package	$current	-	error	$repo	-")
      continue
    fi

    latest="$(normalize_tag "$raw_tag")"
    status="same"
    if [[ "$latest" != "$current" ]]; then
      status="update"
    fi

    rows+=("$package	$current	$latest	$status	$repo	$raw_tag")
  done < <(collect_packages)

  case "$FORMAT" in
    table)
      printf '%s\n' "${rows[@]}" | print_table
      ;;
    tsv)
      printf '%s\n' "${rows[@]}"
      ;;
    json)
      printf '%s\n' "${rows[@]}" | jq -R -s '
        split("\n")
        | map(select(length > 0))
        | map(split("\t"))
        | map({package: .[0], current: .[1], latest: .[2], status: .[3], repo: .[4], raw_tag: .[5]})
      '
      ;;
    *)
      echo "error: unsupported format: $FORMAT" >&2
      exit 1
      ;;
  esac
}

main "$@"
