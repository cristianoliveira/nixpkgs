---
name: add-nix-package
description: Add a new package to this NUR-style nixpkgs repository. Use when asked to create or update a package under pkgs/, wire it into exports, and verify it with nix run .#<package> -- --help and nix flake check.
---

# Add Nix Package

Use this workflow to add a new package to this repository with the same conventions used by existing packages.

## Workflow

1. Inspect current conventions
   - Review `AGENTS.md` for required checks.
   - Review `pkgs/default.nix` to follow export style.
   - Inspect 1-2 similar packages in `pkgs/<name>/default.nix`.
   - Check `./skills/add-nix-package/references/` depending on stack of the package.

   - Search GitHub for proven patterns (recommended)
     - Start with `NixOS/nixpkgs` (highest signal), then broaden to all of GitHub if needed.

     - Search in `NixOS/nixpkgs` first
       - Find an exact upstream repo packaged in nixpkgs:
         - `gh search code "owner/repo" -R NixOS/nixpkgs --limit 20`
       - Find patterns by builder:
         - `gh search code "buildGoModule" -R NixOS/nixpkgs --limit 20`
         - `gh search code "buildRustPackage" -R NixOS/nixpkgs --limit 20`
         - `gh search code "buildNpmPackage" -R NixOS/nixpkgs --limit 20`
       - Find patterns by artifact type:
         - `gh search code "fetchzip" -R NixOS/nixpkgs --limit 20`
         - `gh search code "installShellFiles" -R NixOS/nixpkgs --limit 20`

     - If nixpkgs has no close match, broaden to all GitHub
       - Use GitHub search qualifiers you already use (`path:*.nix <appname>`) and translate them into `gh` flags:
         - GitHub web:
           - `path:*.nix <appname>`
         - `gh` equivalent:
           - `gh search code "<appname>" --extension nix --limit 50`

       - Same pattern queries, but without `-R NixOS/nixpkgs`:
         - `gh search code "buildRustPackage" --extension nix --limit 50`
       - Prefer narrowing by owner/org where possible:
         - `gh search code "buildRustPackage" --extension nix --owner NixOS --limit 50`
         - `gh search code "buildRustPackage" --extension nix --owner numtide --limit 50`
       - Also useful: search by path (matches file path instead of file content)
         - `gh search code "package.nix" --match path --limit 50`
         - `gh search code "default.nix" --match path --limit 50`

     - When you find a close match, mirror the structure and phases, then adapt variables (version/url/hash/meta).

2. Create the package file
   - Create `pkgs/<mypackage>/default.nix`.
   - Export an attribute set from that file:
     - Shape: `pkgs: { <mypackage> = ...; }`
     - Keep naming consistent between directory, attribute name, and binary command.
   - Include practical metadata in `meta` (`description`, `homepage`, `license`, `platforms`).

3. Wire package export
   - Update `pkgs/default.nix` with one new export line:
     - `inherit (import ./<mypackage> pkgs) <mypackage>;`
   - If the package file exports multiple attrs, list all intended attrs explicitly.

4. Validate package entrypoints
   - Ensure install phase places binaries in `$out/bin`.
   - Ensure CLI binary is executable and matches expected command name.
   - Confirm any platform conditionals (`darwin`/`linux`, `aarch64`/`x86_64`) are intentional.

 5. Run required quality checks
    - `nix run .#<mypackage> -- --help`
    - `nix flake check`

 6. Stage package files
    - Ensure package nix files are staged to git before finishing.

## Repository Wiring Notes

- Local packages are exposed through `pkgs/default.nix` and automatically included in `flake.nix` via `localPackages = import (self + /pkgs) pkgs`.
- Usually, adding a local package does **not** require editing `flake.nix` unless a new external flake input is needed.

## Stack References

- For stack-specific packaging patterns, use the concise references in `skills/add-nix-package/references/`.
- Start with `skills/add-nix-package/references/README.md`, then pick the matching stack doc (Go, Rust, Node, Python, binary releases).
