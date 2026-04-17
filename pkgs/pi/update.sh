#!/usr/bin/env bash
set - euo pipefail

  repo="badlogic/pi-mono"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
default_nix="${script_dir}/default.nix"

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1 || ! command -v nix >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
echo "error: requires curl, jq, nix, and python3 in PATH" >&2
exit 1
fi

if [[ $# -gt 1 ]]; then
echo "usage: $0 [version|latest]" >&2
exit 1
fi

requested="${1:-latest}"

if [[ -n "${requested}" && "${requested}" != "latest" && "${requested}" != "undefined" ]]; then
version="${requested#v}"
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
nix store prefetch-file --json "$url" | jq -r '.hash'
}

base_url="https://github.com/${repo}/releases/download/v${version}"
darwin_arm64_url="${base_url}/pi-darwin-arm64.tar.gz"
darwin_x64_url="${base_url}/pi-darwin-x64.tar.gz"
linux_arm64_url="${base_url}/pi-linux-arm64.tar.gz"
linux_x64_url="${base_url}/pi-linux-x64.tar.gz"

darwin_arm64_hash="$(prefetch_sri "${darwin_arm64_url}")"
darwin_x64_hash="$(prefetch_sri "${darwin_x64_url}")"
linux_arm64_hash="$(prefetch_sri "${linux_arm64_url}")"
linux_x64_hash="$(prefetch_sri "${linux_x64_url}")"

python3 - "$default_nix" "$version" "$darwin_arm64_hash" "$darwin_x64_hash" "$linux_arm64_hash" "$linux_x64_hash" <<'PY'
from pathlib import Path
import re
import sys

file_path = Path(sys.argv[1])
version = sys.argv[2]
darwin_arm64 = sys.argv[3]
darwin_x64 = sys.argv[4]
linux_arm64 = sys.argv[5]
linux_x64 = sys.argv[6]

content = file_path.read_text()

content, version_count = re.subn(
r'(?m)^(\s*version = ")[^"]+(";)$',
    rf'\g<1>{version}\g<2>',
    content,
    count=1,
)
if version_count != 1:
    raise SystemExit("error: failed to update version in default.nix")

sha256_block = f'''    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "{darwin_arm64}"
      else "{darwin_x64}"
    else if pkgs.stdenv.isAarch64 then "{linux_arm64}"
    else "{linux_x64}";'''

content, sha_count = re.subn(
    r'(?s)    sha256 = if pkgs\.stdenv\.isDarwin then\n      if pkgs\.stdenv\.isAarch64 then ".*?"\n      else ".*?"\n    else if pkgs\.stdenv\.isAarch64 then ".*?"\n    else ".*?";',
    sha256_block,
    content,
    count=1,
)
if sha_count != 1:
    raise SystemExit("error: failed to update sha256 block in default.nix")

file_path.write_text(content)
PY

echo "Updated pi to v${version}"
echo "- darwin arm64: ${darwin_arm64_hash}"
echo "- darwin x64:   ${darwin_x64_hash}"
echo "- linux arm64:  ${linux_arm64_hash}"
echo "- linux x64:    ${linux_x64_hash}"

echo "Done."

