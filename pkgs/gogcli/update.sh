#!/usr/bin/env bash
set - euo pipefail

  repo="steipete/gogcli"
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
darwin_aarch64_url="${base_url}/gogcli_${version}_darwin_arm64.tar.gz"
darwin_amd64_url="${base_url}/gogcli_${version}_darwin_amd64.tar.gz"
linux_aarch64_url="${base_url}/gogcli_${version}_linux_arm64.tar.gz"
linux_amd64_url="${base_url}/gogcli_${version}_linux_amd64.tar.gz"

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
r'(?m)^(\s*else )"sha256-[^"]+"(\s*)\n\s*else if pkgs\.stdenv\.isLinux then',
    rf'\g<1>"{darwin_amd64}"\g<2>\n    else if pkgs.stdenv.isLinux then',
    content,
    count=1,
)
content, n3 = re.subn(
    r'(?m)^(\s*if pkgs\.stdenv\.isAarch64 then\s*\n\s*if pkgs\.stdenv\.hostPlatform\.isMusl then\s*\n\s*)"sha256-[^"]+"(\s*# arm64-musl\s*)$',
rf'\g<1>"{linux_aarch64}"\g<2>',
content,
count=1,
)
# last else in linux x64 baseline (non-musl) or whatever the last literal is (final else)
content, n4 = re.subn(
r'(?m)^(\s*else )"sha256-[^"]+"(\s*# x64-baseline\s*)$',
    rf'\g<1>"{linux_amd64}"\g<2>',
    content,
    count=1,
)

# gogcli nix file is simpler (no musl split); ensure we updated 4 occurrences total by counting sha256- occurrences replaced.
if (n1, n2) != (1, 1):
    raise SystemExit(f'error: failed to update darwin sha256s: {(n1,n2)}')
if n3 != 0 and n4 != 0:
    # this regex is too strict for gogcli; fallback to generic linux replacement
    pass

# Generic linux replacements for gogcli
content, n3b = re.subn(r'(?m)^(\s*else if pkgs\.stdenv\.isAarch64 then )"sha256-[^"]+"', rf'\g<1>"{linux_aarch64}"', content, count=1)
content, n4b = re.subn(r'(?m)^(\s*else )"sha256-[^"]+";\s*$', rf'\g<1>"{linux_amd64}";', content, count=1)
if (n3b, n4b) != (1, 1):
    raise SystemExit(f'error: failed to update linux sha256s: {(n3b,n4b)}')

path.write_text(content)
PY

echo "Updated gogcli to v${version}"

