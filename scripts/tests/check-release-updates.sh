#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$workdir/pkgs/foo" "$workdir/pkgs/bar"
mkdir -p "$workdir/api/example/foo/releases" "$workdir/api/example/bar/releases"

cat > "$workdir/pkgs/foo/update.sh" <<'EOF'
repo="example/foo"
EOF

cat > "$workdir/pkgs/foo/default.nix" <<'EOF'
{
  version = "1.2.3";
}
EOF

cat > "$workdir/pkgs/bar/update.sh" <<'EOF'
repo="example/bar"
EOF

cat > "$workdir/pkgs/bar/default.nix" <<'EOF'
{
  version = "0.9.0";
}
EOF

cat > "$workdir/api/example/foo/releases/latest" <<'EOF'
{"tag_name":"v1.2.3"}
EOF

cat > "$workdir/api/example/bar/releases/latest" <<'EOF'
{"tag_name":"rust-v1.0.0"}
EOF

out="$workdir/out.tsv"
PKGS_DIR="$workdir/pkgs" \
GITHUB_API_BASE="file://$workdir/api" \
"$root/scripts/check-release-updates.sh" --format tsv > "$out"

rg '^foo\t1\.2\.3\t1\.2\.3\tsame\texample/foo\tv1\.2\.3$' "$out" >/dev/null
rg '^bar\t0\.9\.0\t1\.0\.0\tupdate\texample/bar\trust-v1\.0\.0$' "$out" >/dev/null

echo "ok: check-release-updates"
