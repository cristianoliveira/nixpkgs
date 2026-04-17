#!/usr/bin/env bash
set - euo pipefail

  # Shared helpers for package update scripts.

  require_cmds
  () {
    local missing = ()
      for
      c in "$@";
    do
      command -v "$c" >/dev/null 2>&1 || missing+ =
      ("$c")
        done
      if ((${#missing[@]} > 0)); then
      echo "error: missing required commands: ${missing[*]}" >&2
      exit 1
      fi
      }

      github_latest_tag() {
      local repo="$1" # owner/name
      curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name'
      }

      # Returns SRI sha256-... for a URL.
      prefetch_url_sri() {
      local url="$1"	# nix-prefetch-url returns nix-base32 by default
      local hash
      hash="$(nix-prefetch-url --type sha256 "$url")"
      nix hash convert --hash-algo sha256 "$hash"
      }

      # Parse the first "got: sha256-..." from nix stderr.
      extract_got_sri() {
      local text="$1"
      # shellcheck disable=SC2001
      echo "$text" | sed -n 's/^[[:space:]]*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]*\).*$/\1/p' | head -n1
      }

      # Runs a nix build expected to fail with fixed-output hash mismatch.
      # Prints the "got" SRI if found.
      get_hash_from_build_failure() {
      local attr="$1"
      local out
      set +e
      out="$(nix build ".#${attr}" 2>&1)"
      local code=$?
      set -e
      if [[ $code -eq 0 ]];
    then
    # Build succeeded; no hash needed.
    echo ""
    return 0
    fi
    extract_got_sri "$out"
    }
