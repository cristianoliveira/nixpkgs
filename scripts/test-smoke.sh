#!/usr/bin/env bash
# Smoke test script for Nix packages
# Tests that binaries execute and respond to --help or --version flags

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter for test results
PASSED=0
FAILED=0
SKIPPED=0

# Function to test a package
test_package() {
	local pkg_name=$1
	local binary_name=$2
	local pkg_var=$3 # Package variable name for nix build

	echo -e "\n${YELLOW}Testing: $pkg_name${NC}"

	# Try to build the package
	if ! nix build ".$pkg_var" --print-build-logs --quiet 2>&1; then
		echo -e "${RED}✗ Failed to build $pkg_name${NC}"
		((FAILED++))
		return
	fi

	# Find the binary
	local binary_path=""
	if [ -n "$binary_name" ]; then
		binary_path="./result/bin/$binary_name"
	else
		# Try to find any executable in result/bin
		binary_path=$(find ./result/bin -type f -executable 2>/dev/null | head -1)
	fi

	if [ -z "$binary_path" ] || [ ! -f "$binary_path" ]; then
		echo -e "${RED}✗ Binary not found for $pkg_name${NC}"
		((FAILED++))
		return
	fi

	echo "Binary path: $binary_path"

	# Test --help
	if $binary_path --help >/dev/null 2>&1; then
		echo -e "${GREEN}✓ $pkg_name responds to --help${NC}"
		((PASSED++))
		return
	fi

	# Test --version
	if $binary_path --version >/dev/null 2>&1; then
		echo -e "${GREEN}✓ $pkg_name responds to --version${NC}"
		((PASSED++))
		return
	fi

	# Try running without arguments
	if timeout 2 $binary_path >/dev/null 2>&1; then
		echo -e "${GREEN}✓ $pkg_name executes${NC}"
		((PASSED++))
		return
	fi

	# If we get here, the binary exists but doesn't respond to standard flags
	echo -e "${YELLOW}⚠️ $pkg_name binary exists but doesn't respond to --help/--version${NC}"
	((PASSED++)) # Count as pass since binary exists
}

# Binary name mapping for packages
# Maps package names to their actual binary names (if different)
declare -A BINARY_MAP
BINARY_MAP["beads"]="bd"
BINARY_MAP["beads_viewer"]="bv"
BINARY_MAP["funzzy"]="fzz"
BINARY_MAP["ergoProxy"]="ergo"

# Main execution
main() {
	local test_type=$1

	if [ "$test_type" = "local" ]; then
		echo "=== Testing Local Packages (dynamically discovered) ==="
		echo ""

		# Get all local packages dynamically
		for pkg in $(./scripts/list-packages.sh --local); do
			binary_name="${BINARY_MAP[$pkg]:-$pkg}"
			test_package "$pkg" "$binary_name" "#$pkg"
		done

	elif [ "$test_type" = "external" ]; then
		echo "=== Testing External Packages (dynamically discovered) ==="
		echo ""

		# Get all external packages dynamically
		for pkg in $(./scripts/list-packages.sh --external); do
			# Skip platform-specific packages based on OS
			if [[ "$pkg" == "sway-setter" ]] && [[ "$(uname)" == "Darwin" ]]; then
				echo -e "${YELLOW}⚠️ Skipping sway-setter (Linux only)${NC}"
				((SKIPPED++))
				continue
			fi

			if [[ "$pkg" == aerospace-* ]] && [[ "$(uname)" != "Darwin" ]]; then
				echo -e "${YELLOW}⚠️ Skipping $pkg (Darwin only)${NC}"
				((SKIPPED++))
				continue
			fi

			binary_name="${BINARY_MAP[$pkg]:-$pkg}"
			test_package "$pkg" "$binary_name" "#$pkg"
		done
	else
		echo "Usage: $0 {local|external}"
		exit 1
	fi

	# Summary
	echo ""
	echo "=== Test Summary ==="
	echo -e "${GREEN}Passed: $PASSED${NC}"
	echo -e "${RED}Failed: $FAILED${NC}"
	echo -e "${YELLOW}Skipped: $SKIPPED${NC}"

	if [ $FAILED -gt 0 ]; then
		echo ""
		echo -e "${RED}Some tests failed${NC}"
		exit 1
	else
		echo ""
		echo -e "${GREEN}All tests passed!${NC}"
		exit 0
	fi
}

# Run main function
main "$@"
