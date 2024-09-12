.PHONY: help
help: ## Lists the available commands. Add a comment with '##' to describe a command.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)\
		| sort\
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

PHONY: check-default
check-default: ## Check if the default.nix is valid
	nix-build --no-out-link -E 'with import <nixpkgs> {}; callPackage ./pkgs/default.nix {}'

PHONY: check-flake
check-flake: ## Check if the flake is valid
	nix flake check --all-systems

PHONY: build-all
build-all: build-ergo build-fzz ## Build all packages
	echo "All done"

PHONY: build-ergo
build-ergo: ## Build ergoProxy and ergoProxyNightly
	nix build .#ergoProxy
	nix build .#ergoProxyNightly

PHONY: build-fzz
build-fzz: ### Build funzzy and funzzyNightly
	nix build .#fzzNightly --verbose
	nix build .#funzzy --verbose

PHONY: bump-fzz
bump-fzz: ## Bump funzzy and funzzyNightly
	sed -i '' 's/sha256-.*=//g' pkgs/funzzy.nix
	sed -i '' 's/sha256-.*=//g' pkgs/funzzy-nightly.nix

PHONY: bump-ergo
bump-ergo: ## Bump ergoProxy and ergoProxyNightly
	sed -i '' 's/sha256-.*=//g' pkgs/ergo-proxy.nix
	sed -i '' 's/sha256-.*=//g' pkgs/ergo-proxy-nightly.nix

PHONY: install-funzzy
install-funzzy: ## Install funzzy
	nix profile install 'github:cristianoliveira/nixpkgs#funzzy'

PHONY: install-funzzy-nightly
install-funzzy-nightly: ## Install funzzyNightly
	nix profile install 'github:cristianoliveira/nixpkgs#funzzyNightly'

PHONY: install-ergo
install-ergo: ## Install ergoProxy
	nix profile install 'github:cristianoliveira/nixpkgs#ergoProxy'

PHONY: install-ergo-nightly
install-ergo-nightly: ## Install ergoProxyNightly
	nix profile install 'github:cristianoliveira/nixpkgs#ergoProxyNightly'
