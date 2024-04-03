PHONY: check-default check-flake
check-default:
	@nix-build --no-out-link -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'

check-flake:
	@nix flake check --all-systems
