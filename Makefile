PHONY: check-default
check-default:
	nix-build --no-out-link -E 'with import <nixpkgs> {}; callPackage ./pkgs/default.nix {}'

PHONY: check-flake
check-flake:
	nix flake check --all-systems

PHONY: build-all
build-all: build-ergo build-fzz
	echo "All done"

PHONY: build-ergo
build-ergo:
	nix build .#ergoProxy
	nix build .#ergoProxyNightly

PHONY: build-fzz
build-fzz:
	nix build .#fzzNightly --verbose
	nix build .#funzzy --verbose

PHONY: bump-fzz
bump-fzz:
	sed -i '' 's/sha256-.*=//g' pkgs/funzzy.nix
	sed -i '' 's/sha256-.*=//g' pkgs/funzzy-nightly.nix

PHONY: bump-ergo
bump-ergo:
	sed -i '' 's/sha256-.*=//g' pkgs/ergo-proxy.nix
	sed -i '' 's/sha256-.*=//g' pkgs/ergo-proxy-nightly.nix

PHONY: install-funzzy
install-funzzy:
	nix profile install 'github:cristianoliveira/nixpkgs#funzzy'

PHONY: install-funzzy-nightly
install-funzzy-nightly:
	nix profile install 'github:cristianoliveira/nixpkgs#funzzyNightly'

PHONY: install-ergo
install-ergo:
	nix profile install 'github:cristianoliveira/nixpkgs#ergoProxy'

PHONY: install-ergo-nightly
install-ergo-nightly:
	nix profile install 'github:cristianoliveira/nixpkgs#ergoProxyNightly'
