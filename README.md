# conixpkgs — Cristian Oliveira's Nix Packages

[![nix ci](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-push-nixbuild.yml/badge.svg)](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-push-nixbuild.yml)
[![pr validation](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-pr-validate.yml/badge.svg)](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-pr-validate.yml)
[![periodic nixbuild](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-schedule-nixbuild.yml/badge.svg)](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-schedule-nixbuild.yml)

Personal collection of packages distributed as a Nix flake. Overlay-ready — inject into `nixpkgs` as `pkgs.co.*`.

## Packages

| Category | Packages |
|----------|----------|
| **AI / Agents** | `jeq` — typed-judgment CLI · `pi` — Pi coding assistant · `opencode` — terminal-first AI editor · `deltoids` — code review in the agentic era · `herdr` — coding agent terminal runtime · `herdr-app` — desktop terminal manager |
| **CLI tools** | `funzzy` / `funzzyNightly` — file watcher · `gob` / `beads` — process & workspace managers · `qmd` — quick markdown · `sway-compat` — macOS-style window switching for Sway · `ulauncher-sway-plus` — Ulauncher extension for Sway |
| **Browser / Web** | `brave` — Brave browser · `surf-cli` — browser automation · `playwright-cli` — Playwright CLI · `putio-cli` — put.io client |
| **Productivity** | `ferrite` — · `codex` — · `confluence-cli` · `teamcity-cli` · `mcp-cli` |
| **Media** | `gogcli` / `goplaces` — GOG client · `opensubtitles` — subtitle CLI |
| **Design / Visual** | `figma-cli` — Figma design data · `pxp` — screenshot comparison · `omasnap` — Wayland screenshot annotation |
| **macOS** | `aerospace-scratchpad` · `aerospace-marks` · `aerospace-gestures` · `handy` |
| **External** | `ergoProxy` · `sway-setter` · `mcpli` / `mcpliFork` |

Package availability varies by platform. Run `make list-packages` or `./scripts/list-packages.sh` for the current list.

## Usage

### Quick install

```sh
# Install a single package
nix profile install github:cristianoliveira/nixpkgs#funzzy

# Try without installing
nix run github:cristianoliveira/nixpkgs#pi -- --help
nix run github:cristianoliveira/nixpkgs#jeq -- version
```

`jeq` uses the verified v0.1.0 release archive for your macOS or Linux architecture. The package checks the archive's published SHA-256 before installing it. `jeq version` reports the release tag and commit.

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

The `herdr-app` command adds a compatible `herdr-core` to PATH; this core is distinct from the `herdr` terminal runtime. On macOS, launching the app bundle directly bypasses that wrapper and may require a separate core installation. The app is available for Linux and Apple Silicon macOS. Upstream release builds enable telemetry by default; disable it in Settings → Privacy or set `HERDR_TELEMETRY=0`. Upstream also checks for updates and can download a core outside Nix when requested.

## Brave updates

`brave` uses upstream binary releases for Linux and macOS. Its packaging is based on the last Nixpkgs Brave derivation. The daily update workflow checks for new releases. Run `python3 pkgs/brave/update.py` to update the stable release and its published hashes; build and test each supported platform before publishing. Brave is security-sensitive: monitor upstream releases and ship security updates promptly. Nixpkgs removed its package because it lacked a committer to maintain timely updates; this repository does not inherit Nixpkgs security maintenance.

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

# Run local file tasks and watch GitHub CI for the current commit
scripts/watch-all.sh
```

`scripts/watch-all.sh` runs the local `fzz` watcher and the finite CI observer
in parallel. A failed `nix ci` run stops the local watcher and returns failure.
The observer waits for the matching GitHub Actions run after a push.

## CI/CD

Automated validation on every push and PR:
- **Flake check** — `nix flake check --all-systems`
- **Build** — all packages on `ubuntu-latest` + `macos-latest`
- **Smoke tests** — every binary runs `--help` / `--version`
- **PR workflow** — only builds changed packages for fast feedback

See [`.github/workflows/`](./.github/workflows) for details.
