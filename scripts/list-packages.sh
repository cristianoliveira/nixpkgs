#!/usr/bin/env bash
# Package discovery script for Nix flakes
# Automatically discovers packages from flake outputs

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Get all packages from flake
get_all_packages() {
	local system=$1
	nix eval ".#packages.${system}" --apply 'pkgs: builtins.attrNames pkgs' 2>/dev/null |
		jq -r '.[]' 2>/dev/null ||
		nix eval ".#packages.${system}" --apply 'pkgs: builtins.concatStringsSep " " (builtins.attrNames pkgs)' --raw 2>/dev/null
}

# Filter local packages (those with directories in pkgs/)
filter_local_packages() {
	local packages=$1
	local local_pkgs=()

	for pkg in $packages; do
		# Check if the package has a corresponding directory in pkgs/
		if [[ -d "pkgs/${pkg}" ]]; then
			local_pkgs+=("$pkg")
		fi
	done

	echo "${local_pkgs[*]}"
}

# Filter external packages (those NOT in pkgs/)
filter_external_packages() {
	local packages=$1
	local external_pkgs=()

	for pkg in $packages; do
		# External packages are those without a corresponding directory in pkgs/
		if [[ ! -d "pkgs/${pkg}" ]]; then
			external_pkgs+=("$pkg")
		fi
	done

	echo "${external_pkgs[*]}"
}

# Display usage
show_usage() {
	cat <<EOF
Usage: $0 [OPTIONS]

Discover packages from the Nix flake automatically.

OPTIONS:
    --all          List all packages (default)
    --local        List only local packages (from pkgs/ directory)
    --external     List only external packages (from flake inputs)
    --system ARCH  Use specific system architecture (auto-detected by default)
    --format FORMAT Output format: 'space' (default, shell-compatible), 'json', 'newline'
    -h, --help     Show this help message

EXAMPLES:
    # List all packages
    $0

    # List only local packages
    $0 --local

    # List only external packages
    $0 --external

    # Get packages as JSON
    $0 --format json

    # Get packages one per line
    $0 --format newline

OUTPUT FORMATS:
    space      Space-separated list (for shell usage in Makefiles)
    json       JSON array format
    newline    One package per line

EOF
}

# Main function
main() {
	local show_all=true
	local show_local=false
	local show_external=false
	local system=""
	local format="space"

	# Parse arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
		--all)
			show_all=true
			show_local=false
			show_external=false
			shift
			;;
		--local)
			show_all=false
			show_local=true
			show_external=false
			shift
			;;
		--external)
			show_all=false
			show_local=false
			show_external=true
			shift
			;;
		--system)
			system="$2"
			shift 2
			;;
		--format)
			format="$2"
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

	# Get all packages
	local all_packages
	all_packages=$(get_all_packages "$system")

	if [[ -z "$all_packages" ]]; then
		echo -e "${RED}Error: No packages found or flake evaluation failed${NC}"
		exit 1
	fi

	# Filter packages based on request
	local packages
	if [[ "$show_all" == "true" ]]; then
		packages="$all_packages"
	elif [[ "$show_local" == "true" ]]; then
		packages=$(filter_local_packages "$all_packages")
	elif [[ "$show_external" == "true" ]]; then
		packages=$(filter_external_packages "$all_packages")
	fi

	# Handle empty results
	if [[ -z "$packages" ]]; then
		if [[ "$show_local" == "true" ]]; then
			echo -e "${YELLOW}Warning: No local packages found${NC}"
		elif [[ "$show_external" == "true" ]]; then
			echo -e "${YELLOW}Warning: No external packages found${NC}"
		fi
		exit 0
	fi

	# Output in requested format
	case "$format" in
	json)
		# Convert to JSON array
		local json_array="["
		local first=true
		for pkg in $packages; do
			if [[ "$first" == "true" ]]; then
				json_array+="\"$pkg\""
				first=false
			else
				json_array+=", \"$pkg\""
			fi
		done
		json_array+="]"
		echo "$json_array"
		;;
	newline)
		for pkg in $packages; do
			echo "$pkg"
		done
		;;
	space | *)
		# Default: space-separated
		echo "$packages"
		;;
	esac
}

# Run main function
main "$@"
