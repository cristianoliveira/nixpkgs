#!/usr/bin/env bash
set - euo pipefail

  repo="philschmid/mcp-cli"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
default_nix="${script_dir}/default.nix"

# shellcheck source=../../scripts/update-lib.sh
source "${script_dir}/../../scripts/update-lib.sh"

require_cmds curl jq nix-prefetch-url nix python3

if [[ $# -gt 1 ]]; then
echo "usage: $0 [version]" >&2
exit 1
fi

if [[ $# -eq 1 ]]; then
version="${1#v}"
else
latest_tag="$(github_latest_tag "$repo")"
[[ -n "$latest_tag" && "$latest_tag" != "null" ]] || {
echo "error: failed to determine latest release tag for $repo" >&2
exit 1
}
version="${latest_tag#v}"
fi

base_url="https://github.com/${repo}/releases/download/v${version}"
darwin_arm64_url="${base_url}/mcp-cli-darwin-arm64"
darwin_x64_url="${base_url}/mcp-cli-darwin-x64"
linux_x64_url="${base_url}/mcp-cli-linux-x64"

darwin_arm64_hash="$(prefetch_url_sri "$darwin_arm64_url")"
darwin_x64_hash="$(prefetch_url_sri "$darwin_x64_url")"
linux_x64_hash="$(prefetch_url_sri "$linux_x64_url")"

python3 - "$default_nix" "$version" "$darwin_arm64_hash" "$darwin_x64_hash" "$linux_x64_hash" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
version = sys.argv[2]
darwin_arm64 = sys.argv[3]
darwin_x64 = sys.argv[4]
linux_x64 = sys.argv[5]

content = path.read_text()

content, n = re.subn(r'(?m)^(\s*version = ")[^"]+(";.*)$', rf'\g<1>{version}\g<2>', content, count=1)
if n != 1:
    raise SystemExit('error: failed to update version')

# darwin aarch64
content, n1 = re.subn(
    r'(?m)^(\s*if pkgs\.stdenv\.isDarwin then\s*\n\s*if pkgs\.stdenv\.isAarch64 then )"sha256-[^"]+"',
rf'\g<1>"{darwin_arm64}"',
content,
count=1,
)
# darwin x64
content, n2 = re.subn(
r'(?m)^(\s*else )"sha256-[^"]+"(\s*)\n\s*else if pkgs\.stdenv\.isLinux',
    rf'\g<1>"{darwin_x64}"\g<2>\n    else if pkgs.stdenv.isLinux',
    content,
    count=1,
)
# linux x64
content, n3 = re.subn(
    r'(?m)^(\s*else if pkgs\.stdenv\.isLinux && pkgs\.stdenv\.isx86_64 then )"sha256-[^"]+"',
rf'\g<1>"{linux_x64}"',
content,
count=1,
)

if (n1, n2, n3) != (1, 1, 1):
raise SystemExit(f'error: failed to update sha256s: {(n1,n2,n3)}')

path.write_text(content)
PY

echo "Updated mcp-cli to v${version}"
