PHONY: check-default
check-default:
	@nix-build --no-out-link -E 'with import <nixpkgs> {}; callPackage ./pkgs/default.nix {}'

PHONY: check-flake
check-flake:
	@nix flake check --all-systems

PHONY: build-all
build-all:
	@nix build .#funzzy
	@nix build .#ergoProxy
	@nix build .#ergoProxyNightly

PHONY: build-ergo
build-ergo:
	@nix build .#ergoProxy
	@nix build .#ergoProxyNightly

PHONY: build-fzz
build-fzz:
	@nix build .#funzzy
