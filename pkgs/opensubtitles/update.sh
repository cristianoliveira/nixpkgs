#!/usr/bin/env bash
set - euo pipefail

  repo="emericg/OpenSubtitlesDownload"
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

tarball_url="https://github.com/${repo}/archive/refs/tags/v${version}.tar.gz"
src_hash="$(prefetch_url_sri "$tarball_url")"

python3 - "$default_nix" "$version" "$src_hash" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
version = sys.argv[2]
src_hash = sys.argv[3]

s = path.read_text()

s, n1 = re.subn(r'(?m)^(\s*version = ")[^"]+(";)$', rf'\g<1>{version}\g<2>', s, count=1)
if n1 != 1:
    raise SystemExit('error: failed to update version')

s, n2 = re.subn(r'(?m)^(\s*hash = )"sha256-[^"]+(";)$', rf'\g<1>"{src_hash}"\g<2>', s, count=1)
if n2 != 1:
raise SystemExit('error: failed to update src hash')

path.write_text(s)
PY

echo "Updated opensubtitles to v${version}"
