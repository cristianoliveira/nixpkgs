#!/usr/bin/env bash
# Check for package updates and generate update PRs
# This script checks for updates in packages that have update scripts or can be updated automatically

set - euo pipefail

  # Color codes for output
  RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*" >&2; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*" >&2; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Output file for update report
REPORT_FILE="${REPO_ROOT}/package-updates.md"
TMP_DIR="${REPO_ROOT}/.tmp/update-check"

# Ensure temp directory exists
mkdir -p "$TMP_DIR"

# List of packages with their update scripts/methods
declare -A PACKAGE_UPDATE_METHODS=(
["pi"]="script:pkgs/pi/update.sh"
["opencode"]="script:pkgs/opencode/upgrade-opencode"

# Binary releases with per-platform hashes
["beads"]="script:pkgs/beads/update.sh"
["beads_viewer"]="script:pkgs/beads_viewer/update.sh"
["gob"]="script:pkgs/gob/update.sh"
["gogcli"]="script:pkgs/gogcli/update.sh"
["goplaces"]="script:pkgs/goplaces/update.sh"
["mcp-cli"]="script:pkgs/mcp-cli/update.sh"
["ferrite"]="script:pkgs/ferrite/update.sh"
["codex"]="script:pkgs/codex/update.sh"

# Source-based packages
["confluence-cli"]="script:pkgs/confluence-cli/update.sh"
["opensubtitles"]="script:pkgs/opensubtitles/update.sh"
["playwright-cli"]="script:pkgs/playwright-cli/update.sh"
["putio-cli"]="script:pkgs/putio-cli/update.sh"
)

# Packages to check for rust updates (from GitHub)
declare -A RUST_PACKAGES=(
["zeroclaw"]="https://github.com/zeroclaw-labs/zeroclaw"
["zclaw"]="https://github.com/cristianoliveira/zclaw"
["ferrite"]="https://github.com/juanibiapina/ferrite"
["mcp-cli"]="https://github.com/cristianoliveira/mcp-cli"
["qmd"]="https://github.com/cristianoliveira/qmd"
["gogcli"]="https://github.com/cristianoliveira/gogcli"
["goplaces"]="https://github.com/cristianoliveira/goplaces"
)

# Check if a package has an update script
check_update_script() {
local pkg=$1
local method=""

# Check if package exists in the array
if [[ -n "${PACKAGE_UPDATE_METHODS[$pkg]+isset}" ]]; then
method="${PACKAGE_UPDATE_METHODS[$pkg]}"
fi

if [[ -z "$method" ]]; then
return 1
fi

if [[ "$method" == script:* ]]; then
local script="${method#script:}"
if [[ -f "${REPO_ROOT}/${script}" ]]; then
echo "$script"
return 0
fi
fi

return 1
}

# Run update script for a package
run_update_script() {
  local pkg=$1
  local script=$2
  local original_dir="$(pwd)"

  log_info "Running update script for $pkg..."

  cd "${REPO_ROOT}"

  if bash "${script}"; then
    log_success "Update script for $pkg completed successfully"

    # Check if there are changes
    if git diff --quiet "pkgs/${pkg}/"; then
      log_info "No changes detected for $pkg (already up to date)"
      cd "$original_dir"
      return 1
    else
      cd "$original_dir"
      return 0
    fi
  else
    log_error "Update script for $pkg failed"
    cd "$original_dir"
    return 2
  fi
}

# Check GitHub API for latest release of a rust package
check_rust_package_update() {
  local pkg=$1
  local repo_url=$2
  local repo_owner repo_name

  # Parse owner and repo from URL
  repo_owner=$(echo "$repo_url" | sed -n 's|https://github.com/\([^/]*\)/.*|\1|p')
  repo_name=$(echo "$repo_url" | sed -n 's|https://github.com/[^/]*/\([^/]*\).*|\1|p')

  log_info "Checking GitHub for latest release of ${repo_owner}/${repo_name}..."

  # Get current version from package file
  local pkg_file="${REPO_ROOT}/pkgs/${pkg}/default.nix"
  if [[ ! -f "$pkg_file" ]]; then
    log_warning "Package file not found for $pkg"
    return 1
  fi

  local current_version
  current_version=$(grep -E '^    version = "' "$pkg_file" | sed 's/.*version = "\([^"]*\)".*/\1/')

  if [[ -z "$current_version" ]]; then
    log_warning "Could not determine current version for $pkg"
    return 1
  fi

  log_info "Current version: $current_version"

  # Get latest release from GitHub API with retry logic
  local api_url="https://api.github.com/repos/${repo_owner}/${repo_name}/releases/latest"
  local latest_tag latest_version
  local max_retries=3
  local retry_count=0

  while [ $retry_count -lt $max_retries ]; do
    if ! latest_tag=$(curl -s -f "$api_url" 2>&1 | jq -r '.tag_name'); then
      retry_count=$((retry_count + 1))
      if [ $retry_count -lt $max_retries ]; then
        log_warning "GitHub API request failed (attempt $retry_count/$max_retries), retrying..."
        sleep 2
        continue
      else
        log_warning "Failed to fetch latest release for ${repo_owner}/${repo_name} after $max_retries attempts"
        return 1
      fi
    fi
    break
  done

  if [[ "$latest_tag" == "null" ]] || [[ -z "$latest_tag" ]]; then
    log_warning "No releases found for ${repo_owner}/${repo_name}"
    return 1
  fi

  latest_version="${latest_tag#v}"
log_info "Latest version: $latest_version"

# Compare versions
if [[ "$current_version" == "$latest_version" ]]; then
log_info "Package $pkg is already up to date"
return 1
fi

# Check if newer version exists
if ! nix-env -qP --compare-versions "$current_version" -lt "$latest_version" 2>/dev/null; then
# Fall back to string comparison
if [[ "$current_version" < "$latest_version" ]]; then
log_success "Update available for $pkg: $current_version → $latest_version"
return 0
else
log_info "Package $pkg is already up to date"
return 1
fi
else
log_success "Update available for $pkg: $current_version → $latest_version"
return 0
fi
}

# Generate update instructions for rust package
generate_rust_update_instructions() {
local pkg=$1
local repo_url=$2
local repo_owner repo_name

repo_owner=$(echo "$repo_url" | sed -n 's|https://github.com/\([^/]*\)/.*|\1|p')
repo_name=$(echo "$repo_url" | sed -n 's|https://github.com/[^/]*/\([^/]*\).*|\1|p')

local pkg_file="${REPO_ROOT}/pkgs/${pkg}/default.nix"
local current_version
current_version=$(grep -E '^    version = "' "$pkg_file" | sed 's/.*version = "\([^"]*\)".*/\1/')

# Get latest version with error handling
local api_url="https://api.github.com/repos/${repo_owner}/${repo_name}/releases/latest"
local latest_tag latest_version
local max_retries=3
local retry_count=0

while [ $retry_count -lt $max_retries ]; do
if ! latest_tag=$(curl -s -f "$api_url" 2>&1 | jq -r '.tag_name'); then
retry_count=$((retry_count + 1))
if [ $retry_count -lt $max_retries ]; then
log_warning "Failed to fetch release for ${repo_owner}/${repo_name}, retrying..."
sleep 2
continue
else
log_warning "Could not fetch release info for $pkg"
return 1
fi
fi
break
done

latest_version="${latest_tag#v}"

# Get latest commit SHA with error handling
local commit_sha
retry_count=0
while [ $retry_count -lt $max_retries ]; do
if ! commit_sha=$(curl -s -f "https://api.github.com/repos/${repo_owner}/${repo_name}/commits/master" 2>&1 | jq -r '.sha'); then
retry_count=$((retry_count + 1))
if [ $retry_count -lt $max_retries ]; then
log_warning "Failed to fetch commit for ${repo_owner}/${repo_name}, retrying..."
sleep 2
continue
else
log_warning "Could not fetch commit SHA for $pkg"
commit_sha="<fetch-latest-sha-from-github>"
fi
fi
break
done

echo "### $pkg"
echo ""
echo "**Current version:** $current_version"
echo "**Latest version:** $latest_version"
echo ""
echo "#### Update Instructions:"
echo ""
echo "1. Update the version in \`pkgs/${pkg}/default.nix\`:"
echo '```nix'
echo "version = \"${latest_version}\";"
echo '```'
echo ""
echo "2. Update the commit SHA in \`pkgs/${pkg}/default.nix\`:"
echo '```nix'
echo "rev = \"${commit_sha}\";"
echo '```'
echo ""
echo "3. Update the source hash by building the package (Nix will tell you the correct hash):"
echo '```bash'
echo "nix build .#${pkg}"
echo '```'
echo ""
echo "4. After getting the correct hash, update it in \`pkgs/${pkg}/default.nix\`:"
echo '```nix'
echo "hash = \"<new-hash>\";"
echo '```'
echo ""
echo "5. Verify the build:"
echo '```bash'
echo "nix build .#${pkg}"
echo "./result/bin/<main-program> --version"
echo '```'
echo ""
echo "#### Resources:"
echo "- Repository: ${repo_url}"
echo "- Release: https://github.com/${repo_owner}/${repo_name}/releases/tag/${latest_tag}"
echo ""
echo "---"
echo ""
}

# Check for updates in a package
check_package_update() {
  local pkg=$1

  log_info "Checking for updates for $pkg..."

  # First check if there's an update script
  if update_script=$(check_update_script "$pkg"); then
    log_info "Found update script for $pkg: $update_script"

    if run_update_script "$pkg" "$update_script"; then
      # Changes were made
      log_success "Update available for $pkg (changes detected)"
      return 0
    elif [[ $? -eq 2 ]]; then
      # Update script failed
      log_error "Failed to check $pkg for updates"
      return 2
    else
      # No changes
      return 1
    fi
  fi

  # Check if it's a rust package
  if [[ -n "${RUST_PACKAGES[$pkg]+isset}" ]]; then
    if check_rust_package_update "$pkg" "${RUST_PACKAGES[$pkg]}"; then
      return 0
    fi
  fi

  return 1
}

# Main function
main() {
  log_info "Checking for package updates..."
  echo ""

  # Get list of all local packages
  local all_packages
  if ! all_packages=$(bash "${SCRIPT_DIR}/list-packages.sh" --local 2>&1); then
    log_error "Failed to get package list"
    printf '{"packages":[]}\n'
    exit 0
  fi

  if [[ -z "$all_packages" ]]; then
    log_warning "No local packages found"
    printf '{"packages":[]}\n'
    exit 0
  fi

  # Clear report file
  > "$REPORT_FILE"

  # Create report header
  cat > "$REPORT_FILE" <<EOF
# Package Update Report

Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Summary

This report shows packages that have updates available.

EOF

  local packages_with_updates=()

  # Check each package
  for pkg in $all_packages; do
    if check_package_update "$pkg"; then
      packages_with_updates+=("$pkg")
    fi
  done

  # Generate report
  if [[ ${#packages_with_updates[@]} -eq 0 ]]; then
echo "No updates available." >> "$REPORT_FILE"
log_success "All packages are up to date!"
else
echo "" >> "$REPORT_FILE"
echo "## Packages with Updates" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for pkg in "${packages_with_updates[@]}"; do
# Check if there's an update script
if update_script=$(check_update_script "$pkg"); then
# Check if changes were made
cd "${REPO_ROOT}"
if ! git diff --quiet "pkgs/${pkg}/"; then
echo "### $pkg" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**Status:** Ready to commit (changes detected by update script)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "The update script has already updated the package files. Review the changes:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo '```diff' >> "$REPORT_FILE"
git diff "pkgs/${pkg}/" >> "$REPORT_FILE" || true
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
fi
# Check if it's a rust package
elif [[ -n "${RUST_PACKAGES[$pkg]+isset}" ]]; then
generate_rust_update_instructions "$pkg" "${RUST_PACKAGES[$pkg]}" >> "$REPORT_FILE"
fi
done

log_success "Found ${#packages_with_updates[@]} package(s) with updates"
fi

# Output report location
log_info "Update report generated: $REPORT_FILE"

# Export list of packages with updates for GitHub Action
if [[ ${#packages_with_updates[@]} -gt 0 ]]; then
printf '%s\n' "${packages_with_updates[@]}" > "${TMP_DIR}/packages-to-update.txt"

# Create JSON output for GitHub Actions
printf '{"packages":[' > "${TMP_DIR}/updates.json"
local first=true
for pkg in "${packages_with_updates[@]}"; do
if [[ "$first" == "true" ]]; then
printf '"%s"' "$pkg" >> "${TMP_DIR}/updates.json"
first=false
else
printf ',"%s"' "$pkg" >> "${TMP_DIR}/updates.json"
fi
done
printf ']}\n' >> "${TMP_DIR}/updates.json"

# Print JSON to stdout for GitHub Actions to capture
cat "${TMP_DIR}/updates.json"
else
printf '{"packages":[]}\n'
fi

exit 0
}

# Run main function
main "$@"
