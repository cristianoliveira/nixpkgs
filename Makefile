PHONY: check-default
check-default:
	@nix-build --no-out-link -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
