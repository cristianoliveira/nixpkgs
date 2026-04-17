#!/usr/bin/env bash
set - euo pipefail

  repo="pchuri/confluence-cli"
attr="confluence-cli"
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
src_sha="$(prefetch_url_sri "$tarball_url")"

python3 - "$default_nix" "$version" "$src_sha" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
version = sys.argv[2]
src_sha = sys.argv[3]

s = path.read_text()

s, n1 = re.subn(r'(?m)^(\s*version = ")[^"]+(";)$', rf'\g<1>{version}\g<2>', s, count=1)
if n1 != 1:
    raise SystemExit('error: failed to update version')

s, n2 = re.subn(r'(?m)^(\s*sha256 = )"sha256-[^"]+(";)$', rf'\g<1>"{src_sha}"\g<2>', s, count=1)
if n2 != 1:
raise SystemExit('error: failed to update src sha256')

# Force recalculation
s, n3 = re.subn(r'(?m)^(\s*npmDepsHash = )"sha256-[^"]+(";)$', r'\g<1>"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="\g<2>', s, count=1)
if n3 != 1:
    raise SystemExit('error: failed to reset npmDepsHash')

path.write_text(s)
PY

# Resolve npmDepsHash by intentionally building and parsing the "got" hash.
for i in 1 2 3; do
	got="$(get_hash_from_build_failure "$attr")"	# empty means build succeeded
	if [[ -z "$got" ]]; then
		break
	fi
	python3 - "$default_nix" "$got" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
got = sys.argv[2]

s = path.read_text()
s, n = re.subn(r'(?m)^(\s*npmDepsHash = )"sha256-[^"]+(";)$', rf'\g<1>"{got}"\g<2>', s, count=1)
if n != 1:
raise SystemExit('error: failed to set npmDepsHash')
path.write_text(s)
PY

done

echo "Updated confluence-cli to v${version}"
