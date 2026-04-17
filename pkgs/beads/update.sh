#!/usr/bin/env bash
set - euo pipefail

  repo="steveyegge/beads"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
default_nix="${script_dir}/default.nix"

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1 || ! command -v nix-prefetch-url >/dev/null 2>&1 || ! command -v nix >/dev/null 2>&1; then
echo "error: requires curl, jq, nix-prefetch-url, and nix in PATH" >&2
exit 1
fi

if [[ $# -gt 1 ]]; then
echo "usage: $0 [version]" >&2
exit 1
fi

if [[ $# -eq 1 ]]; then
version="${1#v}"
else
latest_tag="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name')"
if [[ -z "${latest_tag}" || "${latest_tag}" == "null" ]]; then
echo "error: failed to determine latest release tag from GitHub API" >&2
exit 1
fi
version="${latest_tag#v}"
fi

prefetch_sri() {
local url="$1"
local hash
hash="$(nix-prefetch-url --type sha256 "$url")"
nix hash convert --hash-algo sha256 "$hash"
}

base_url="https://github.com/${repo}/releases/download/v${version}"
darwin_aarch64_url="${base_url}/beads_${version}_darwin_arm64.tar.gz"
darwin_amd64_url="${base_url}/beads_${version}_darwin_amd64.tar.gz"
linux_aarch64_url="${base_url}/beads_${version}_linux_arm64.tar.gz"
linux_amd64_url="${base_url}/beads_${version}_linux_amd64.tar.gz"

darwin_aarch64_hash="$(prefetch_sri "${darwin_aarch64_url}")"
darwin_amd64_hash="$(prefetch_sri "${darwin_amd64_url}")"
linux_aarch64_hash="$(prefetch_sri "${linux_aarch64_url}")"
linux_amd64_hash="$(prefetch_sri "${linux_amd64_url}")"

python3 - "$default_nix" "$version" "$darwin_aarch64_hash" "$darwin_amd64_hash" "$linux_aarch64_hash" "$linux_amd64_hash" <<'PY'
from pathlib import Path
import re
import sys

file_path = Path(sys.argv[1])
version = sys.argv[2]
darwin_aarch64 = sys.argv[3]
darwin_amd64 = sys.argv[4]
linux_aarch64 = sys.argv[5]
linux_amd64 = sys.argv[6]

content = file_path.read_text()

content, version_count = re.subn(
r'(?m)^(\s*version = ")[^"]+(";)$',
    rf'\g<1>{version}\g<2>',
    content,
    count=1,
)
if version_count != 1:
    raise SystemExit("error: failed to update version in default.nix")

hashes_block = f'''    hashes = {{
      darwin = {{
        aarch64 = "{darwin_aarch64}";
        amd64 = "{darwin_amd64}";
      }};
      linux = {{
        aarch64 = "{linux_aarch64}";
        amd64 = "{linux_amd64}";
      }};
    }};'''

content, hashes_count = re.subn(
    r'(?s)    hashes = \{\n.*?\n    \};',
    hashes_block,
    content,
    count=1,
)
if hashes_count != 1:
    raise SystemExit("error: failed to update hashes block in default.nix")

file_path.write_text(content)
PY

echo "Updated beads to v${version}"
echo "- darwin aarch64: ${darwin_aarch64_hash}"
echo "- darwin amd64:   ${darwin_amd64_hash}"
echo "- linux aarch64:  ${linux_aarch64_hash}"
echo "- linux amd64:    ${linux_amd64_hash}"

expected_version="$(nix eval --raw .#beads.version)"
version_output="$(nix run .#beads -- --version 2>&1)"

if [[ "${version_output}" =~ ([0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z]+)*) ]]; then
runtime_version="${BASH_REMATCH[1]}"
else
echo "error: failed to extract version from 'nix run .#beads -- --version' output: ${version_output}" >&2
exit 1
fi

if [[ "${runtime_version}" != "${expected_version}" ]]; then
echo "error: beads runtime version mismatch (expected ${expected_version}, got ${runtime_version})" >&2
echo "version output: ${version_output}" >&2
exit 1
fi

echo "Validated beads runtime version: ${runtime_version}"
