# conixpkgs — Cristian Oliveira's Nix Packages

[![nix ci](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-push-nixbuild.yml/badge.svg)](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-push-nixbuild.yml)
[![pr validation](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-pr-validate.yml/badge.svg)](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-pr-validate.yml)
[![periodic nixbuild](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-schedule-nixbuild.yml/badge.svg)](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-schedule-nixbuild.yml)

Personal collection of packages distributed as a Nix flake. Overlay-ready — inject into `nixpkgs` as `pkgs.co.*`.

## Packages

| Category | Packages |
|----------|----------|
| **AI / Agents** | `pi` — Pi coding assistant · `opencode` — terminal-first AI editor · `deltoids` — code review in the agentic era |
| **CLI tools** | `funzzy` / `funzzyNightly` — file watcher · `gob` / `beads` — process & workspace managers · `qmd` — quick markdown · `zclaw` / `zeroclaw` — git tooling |
| **Browser / Web** | `surf-cli` — browser automation · `playwright-cli` — Playwright CLI · `putio-cli` — put.io client |
| **Productivity** | `ferrite` — · `codex` — · `confluence-cli` · `teamcity-cli` · `mcp-cli` |
| **Media** | `gogcli` / `goplaces` — GOG client · `opensubtitles` — subtitle CLI |
| **macOS** | `aerospace-scratchpad` · `aerospace-marks` · `handy` |
| **External** | `ergoProxy` · `sway-setter` · `mcpli` / `mcpliFork` |

**30 packages** total. Run `make list-packages` or `./scripts/list-packages.sh` for the full dynamic list.

## Usage

### Quick install

```sh
# Install a single package
nix profile install github:cristianoliveira/nixpkgs#funzzy

# Try without installing
nix run github:cristianoliveira/nixpkgs#pi -- --help
```

### As an overlay

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    conixpkgs = {
      url = "github:cristianoliveira/nixpkgs";
      flake = true;
    };
  };

  outputs = { nixpkgs, conixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ ... }: {
          nixpkgs.overlays = [ conixpkgs.overlays.default ];
          environment.systemPackages = with pkgs.co; [
            funzzy
            pi
          ];
        })
      ];
    };
  };
}
```

### In a devShell

```nix
{
  inputs.conixpkgs.url = "github:cristianoliveira/nixpkgs";

  outputs = { nixpkgs, conixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; overlays = [ conixpkgs.overlays.default ]; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ pkgs.co.funzzy pkgs.co.deltoids ];
    };
  };
}
```

## Development

```sh
# Enter dev shell with nixpkgs-fmt, yamllint, gh, jq
nix develop

# Validate flake structure
nix flake check --all-systems

# Build everything
make build-all

# Build only local packages
make build-local

# Build a specific package
nix build .#surf-cli

# Run smoke tests
make test-all

# Full CI locally
make ci-validate

# List packages (dynamic discovery)
make list-packages
```

## CI/CD

Automated validation on every push and PR:
- **Flake check** — `nix flake check --all-systems`
- **Build** — all packages on `ubuntu-latest` + `macos-latest`
- **Smoke tests** — every binary runs `--help` / `--version`
- **PR workflow** — only builds changed packages for fast feedback

See [`.github/workflows/`](./.github/workflows) for details.
