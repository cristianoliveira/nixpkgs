# Rust Pattern (`rustPlatform.buildRustPackage`)

## When to use

- The project is a Rust crate with `Cargo.lock`.
- You are packaging one or more Rust binaries from source.

## Typical helpers and fields

- Helper: `rustPlatform.buildRustPackage`
- Source: `fetchFromGitHub`
- Common fields: `pname`, `version`, `src`, `cargoHash` (or `cargoLock`), `nativeBuildInputs`, `buildInputs`, `meta.mainProgram`

## Minimal snippet

```nix
{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "my-rust-cli";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "org";
    repo = "my-rust-cli";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  cargoHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  meta = with lib; {
    description = "Example Rust CLI";
    license = licenses.asl20;
    mainProgram = "my-rust-cli";
  };
}
```

## Real examples in `.local/nixpkgs/*`

- `.local/nixpkgs/pkgs/tools/admin/procs/default.nix`
- `.local/nixpkgs/pkgs/tools/misc/hyperfine/default.nix`

## Pitfalls and checks

- `cargoHash` changes whenever dependencies or lockfile change.
- Add platform-specific libraries for Darwin/Linux when required by crate features.
- If completion generation runs target binaries during build, use host emulation patterns when cross compiling.
