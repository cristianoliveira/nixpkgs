#!/usr/bin/env bash
# Check overlay injection for nixpkgs overlay
# Verifies that the overlay can be injected and exposes expected attributes

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Determine the current system
get_system() {
	nix eval --raw nixpkgs#system 2>/dev/null || {
		# Fallback to detecting system
		if [[ "$(uname)" == "Darwin" ]]; then
			if [[ "$(uname -m)" == "arm64" ]]; then
				echo "aarch64-darwin"
			else
				echo "x86_64-darwin"
			fi
		else
			if [[ "$(uname -m)" == "aarch64" ]]; then
				echo "aarch64-linux"
			else
				echo "x86_64-linux"
			fi
		fi
	}
}

# Display usage
show_usage() {
	cat <<EOF
Usage: $0 [OPTIONS]

Check that the overlay is injectable and exposes expected attributes.

OPTIONS:
    --system ARCH   Use specific system architecture (auto-detected by default)
    -h, --help      Show this help message

EXAMPLES:
    $0
    $0 --system x86_64-linux

EOF
}

# Main function
main() {
	local system=""

	# Parse arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
		--system)
			system="$2"
			shift 2
			;;
		-h | --help)
			show_usage
			exit 0
			;;
		*)
			echo -e "${RED}Error: Unknown option $1${NC}"
			show_usage
			exit 1
			;;
		esac
	done

	# Auto-detect system if not specified
	if [[ -z "$system" ]]; then
		system=$(get_system)
	fi

	echo -e "${YELLOW}Checking overlay injection for system: $system${NC}"

	# Evaluate the overlay and check co.beads
	echo -e "${YELLOW}Evaluating overlay...${NC}"
	if ! nix eval --impure --expr \
		"let
			flake = builtins.getFlake (toString ./.);
			pkgs = import flake.inputs.nixpkgs {
				system = \"$system\";
				overlays = [ flake.overlays.default ];
			};
		in
			pkgs.co.beads" 2>/dev/null; then
		echo -e "${RED}✗ Overlay injection failed${NC}"
		echo -e "${RED}  Could not evaluate pkgs.co.beads${NC}"
		exit 1
	fi

	# Get the derivation path to ensure it's a valid package
	echo -e "${YELLOW}Checking derivation...${NC}"
	if ! derivation_path=$(nix eval --impure --raw --expr \
		"let
			flake = builtins.getFlake (toString ./.);
			pkgs = import flake.inputs.nixpkgs {
				system = \"$system\";
				overlays = [ flake.overlays.default ];
			};
		in
			pkgs.co.beads" 2>/dev/null); then
		echo -e "${RED}✗ Could not get derivation path for co.beads${NC}"
		exit 1
	fi

	echo -e "${GREEN}✓ Overlay injection successful${NC}"
	echo -e "${GREEN}  Derivation: $derivation_path${NC}"

	# Optional: check that co attribute set exists and contains beads
	# This is redundant but good for clarity
	echo -e "${YELLOW}Checking co attribute set...${NC}"
	if ! nix eval --impure --expr \
		"let
			flake = builtins.getFlake (toString ./.);
			pkgs = import flake.inputs.nixpkgs {
				system = \"$system\";
				overlays = [ flake.overlays.default ];
			};
		in
			builtins.isAttrs pkgs.co && pkgs.co ? beads" 2>/dev/null | grep -q true; then
		echo -e "${RED}✗ co attribute set missing or does not contain beads${NC}"
		exit 1
	fi

	echo -e "${GREEN}✓ co attribute set contains beads${NC}"
	echo -e "${GREEN}All checks passed! Overlay is injectable and exposes expected packages.${NC}"
}

# Run main function
main "$@"
