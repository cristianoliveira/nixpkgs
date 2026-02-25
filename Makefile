# Makefile for Nix package management
#
# Dynamic Package Discovery:
# This Makefile uses scripts/list-packages.sh to automatically discover packages
# from the flake outputs instead of hardcoding package names. This makes the
# build system self-maintaining - when new packages are added to the flake,
# they are automatically discovered and included in build targets.
#
# The discovery script uses `nix eval` to query the flake packages and
# distinguishes between:
#   - Local packages: packages defined in pkgs/ directory
#   - External packages: packages from flake inputs
#
# Usage examples:
#   make list-packages      - List all discovered packages
#   make build-all          - Build all packages (discovered dynamically)
#   make build-local        - Build only local packages
#   make build-external     - Build only external packages

.PHONY: help
help: ## Lists the available commands. Add a comment with '##' to describe a command.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)\
		| sort\
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: list-packages
list-packages: ## List all packages from the flake (dynamic discovery)
	@./scripts/list-packages.sh --format newline

.PHONY: list-local
list-local: ## List only local packages
	@./scripts/list-packages.sh --local --format newline

.PHONY: list-external
list-external: ## List only external packages
	@./scripts/list-packages.sh --external --format newline

.PHONY: check-default
check-default: ## Check if the default.nix is valid
	nix-build --no-out-link -E 'with import <nixpkgs> {}; callPackage ./pkgs/default.nix {}'

.PHONY: check-flake
check-flake: ## Check if the flake is valid
	nix flake check --all-systems

.PHONY: build-all
build-all: ## Build all packages (external + local, dynamically discovered)
	@for pkg in $$(./scripts/list-packages.sh --all); do \
		echo "Building: $$pkg"; \
		nix build ".#$$pkg" || echo "⚠️ Failed to build $$pkg"; \
	done

# External packages (from flakes)
.PHONY: build-ergo
build-ergo: ## Build ergoProxy and ergoProxyNightly
	nix build .#ergoProxy
	nix build .#ergoProxyNightly

.PHONY: build-fzz
build-fzz: ### Build funzzy and funzzyNightly
	nix build .#fzzNightly --verbose
	nix build .#funzzy --verbose

# Dynamic package discovery
.PHONY: build-external
build-external: ## Build all external flake packages (dynamically discovered)
	@for pkg in $$(./scripts/list-packages.sh --external); do \
		echo "Building: $$pkg"; \
		nix build ".#$$pkg" || echo "⚠️ Failed to build $$pkg"; \
	done

# Local packages
.PHONY: build-local
build-local: ## Build all local packages (dynamically discovered)
	@for pkg in $$(./scripts/list-packages.sh --local); do \
		echo "Building: $$pkg"; \
		nix build ".#$$pkg" || echo "⚠️ Failed to build $$pkg"; \
	done

.PHONY: build-opencode
build-opencode: ## Build opencode package
	nix build .#opencode

.PHONY: build-qmd
build-qmd: ## Build qmd package
	nix build .#qmd

.PHONY: build-ferrite
build-ferrite: ## Build ferrite package
	nix build .#ferrite

.PHONY: build-gob
build-gob: ## Build gob package
	nix build .#gob

.PHONY: build-beads
build-beads: ## Build beads package
	nix build .#beads

.PHONY: build-beads_viewer
build-beads_viewer: ## Build beads_viewer package
	nix build .#beads_viewer

.PHONY: build-confluence-cli
build-confluence-cli: ## Build confluence-cli package
	nix build .#confluence-cli

.PHONY: build-codex
build-codex: ## Build codex package
	nix build .#codex

# Testing targets
.PHONY: test-all
test-all: test-local test-external ## Run all tests (smoke tests)

.PHONY: test-local
test-local: ## Run smoke tests for local packages
	@echo "=== Testing local packages ==="
	@./scripts/test-smoke.sh local || echo "⚠️ Some local tests failed"

.PHONY: test-external
test-external: ## Run smoke tests for external packages
	@echo "=== Testing external packages ==="
	@./scripts/test-smoke.sh external || echo "⚠️ Some external tests failed"

.PHONY: ci-validate
ci-validate: check-flake build-all test-all ## Run complete CI validation

# Package maintenance
.PHONY: bump-fzz
bump-fzz: ## Bump funzzy and funzzyNightly
	sed -i '' 's/sha256-.*=//g' pkgs/funzzy.nix
	sed -i '' 's/sha256-.*=//g' pkgs/funzzy-nightly.nix

.PHONY: bump-ergo
bump-ergo: ## Bump ergoProxy and ergoProxyNightly
	sed -i '' 's/sha256-.*=//g' pkgs/ergo-proxy.nix
	sed -i '' 's/sha256-.*=//g' pkgs/ergo-proxy-nightly.nix

# Installation targets
.PHONY: install-funzzy
install-funzzy: ## Install funzzy
	nix profile install 'github:cristianoliveira/nixpkgs#funzzy' --no-write-lock-file

.PHONY: install-funzzy-nightly
install-funzzy-nightly: ## Install funzzyNightly
	nix profile install 'github:cristianoliveira/nixpkgs#funzzyNightly' --no-write-lock-file

.PHONY: install-ergo
install-ergo: ## Install ergoProxy
	nix profile install 'github:cristianoliveira/nixpkgs#ergoProxy' --no-write-lock-file

.PHONY: install-ergo-nightly
install-ergo-nightly: ## Install ergoProxyNightly
	nix profile install 'github:cristianoliveira/nixpkgs#ergoProxyNightly' --no-write-lock-file
