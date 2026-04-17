#!/usr/bin/env bash
set - euo pipefail

  repo="steipete/goplaces"
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
darwin_aarch64_url="${base_url}/goplaces_${version}_darwin_arm64.tar.gz"
darwin_amd64_url="${base_url}/goplaces_${version}_darwin_amd64.tar.gz"
linux_aarch64_url="${base_url}/goplaces_${version}_linux_arm64.tar.gz"
linux_amd64_url="${base_url}/goplaces_${version}_linux_amd64.tar.gz"

darwin_aarch64_hash="$(prefetch_url_sri "$darwin_aarch64_url")"
darwin_amd64_hash="$(prefetch_url_sri "$darwin_amd64_url")"
linux_aarch64_hash="$(prefetch_url_sri "$linux_aarch64_url")"
linux_amd64_hash="$(prefetch_url_sri "$linux_amd64_url")"

python3 - "$default_nix" "$version" "$darwin_aarch64_hash" "$darwin_amd64_hash" "$linux_aarch64_hash" "$linux_amd64_hash" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
version = sys.argv[2]
darwin_aarch64 = sys.argv[3]
darwin_amd64 = sys.argv[4]
linux_aarch64 = sys.argv[5]
linux_amd64 = sys.argv[6]

content = path.read_text()
content, n = re.subn(r'(?m)^(\s*version = ")[^"]+(";.*)$', rf'\g<1>{version}\g<2>', content, count=1)
if n != 1:
    raise SystemExit('error: failed to update version')

content, n1 = re.subn(
    r'(?m)^(\s*if pkgs\.stdenv\.isDarwin then\s*\n\s*if pkgs\.stdenv\.isAarch64 then )"sha256-[^"]+"',
rf'\g<1>"{darwin_aarch64}"',
content,
count=1,
)
content, n2 = re.subn(
r'(?m)^(\s*else )"sha256-[^"]+"(\s*)\n\s*else if pkgs\.stdenv\.isAarch64 then',
    rf'\g<1>"{darwin_amd64}"\g<2>\n    else if pkgs.stdenv.isAarch64 then',
    content,
    count=1,
)
content, n3 = re.subn(
    r'(?m)^(\s*else if pkgs\.stdenv\.isAarch64 then )"sha256-[^"]+"',
rf'\g<1>"{linux_aarch64}"',
content,
count=1,
)
content, n4 = re.subn(
r'(?m)^(\s*else )"sha256-[^"]+";\s*$',
    rf'\g<1>"{linux_amd64}";',
    content,
    count=1,
)

if (n1, n2, n3, n4) != (1, 1, 1, 1):
    raise SystemExit(f'error: failed to update sha256s: {(n1,n2,n3,n4)}')

path.write_text(content)
PY

echo "Updated goplaces to v${version}"

