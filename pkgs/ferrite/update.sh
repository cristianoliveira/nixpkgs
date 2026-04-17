#!/usr/bin/env bash
set - euo pipefail

  repo="OlaProeis/Ferrite"
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
mac_arm64_url="${base_url}/ferrite-macos-arm64.tar.gz"
mac_x64_url="${base_url}/ferrite-macos-x64.tar.gz"
linux_x64_url="${base_url}/ferrite-linux-x64.tar.gz"

mac_arm64_hash="$(prefetch_url_sri "$mac_arm64_url")"
mac_x64_hash="$(prefetch_url_sri "$mac_x64_url")"
linux_x64_hash="$(prefetch_url_sri "$linux_x64_url")"

python3 - "$default_nix" "$version" "$mac_arm64_hash" "$mac_x64_hash" "$linux_x64_hash" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
version = sys.argv[2]
mac_arm64 = sys.argv[3]
mac_x64 = sys.argv[4]
linux_x64 = sys.argv[5]

s = path.read_text()

s, n = re.subn(r'(?m)^(\s*version = ")[^"]+(";.*)$', rf'\g<1>{version}\g<2>', s, count=1)
if n != 1:
    raise SystemExit('error: failed to update version')

# darwin hashes
s, n1 = re.subn(
    r'(?m)^(\s*if pkgs\.stdenv\.isAarch64 then )"sha256-[^"]+"( else\s*)$',
rf'\g<1>"{mac_arm64}"\g<2>',
s,
count=1,
)
s, n2 = re.subn(
r'(?m)^(\s*)"sha256-[^"]+"(\s*)$\n(\s*else if pkgs\.stdenv\.isLinux then)',
    rf'\g<1>"{mac_x64}"\g<2>\n\g<3>',
    s,
    count=1,
)

# linux x64 hash
s, n3 = re.subn(
    r'(?m)^(\s*else )"sha256-[^"]+"(\s*)$\n(\s*else throw "Ferrite v\$\{version\} unsupported platform";)$',
rf'\g<1>"{linux_x64}"\g<2>\n\g<3>',
s,
count=1,
)

if (n1, n2, n3) != (1, 1, 1):
raise SystemExit(f'error: failed to update hashes: {(n1,n2,n3)}')

path.write_text(s)
PY

echo "Updated ferrite to v${version}"
