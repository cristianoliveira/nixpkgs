# Node Pattern (`buildNpmPackage` / `mkYarnPackage`)

## When to use

- The package builds JavaScript/TypeScript assets with npm or yarn.
- You need a reproducible lockfile-based frontend or CLI build.

## Typical helpers and fields

- Helpers: `buildNpmPackage` (preferred for npm lockfiles), `mkYarnPackage` (legacy yarn projects)
- Source: `fetchFromGitHub`
- Common fields: `pname`, `version`, `src`, `npmDepsHash`, `npmBuildScript`, `npmBuildFlags`, `installPhase`, `meta`

## Minimal snippet

```nix
{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "my-node-app";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "org";
    repo = "my-node-app";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/my-node-app
    cp -r dist/* $out/share/my-node-app/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Example Node package";
    license = licenses.mit;
  };
}
```

## Real examples in `.local/nixpkgs/*`

- `.local/nixpkgs/pkgs/tools/security/vaultwarden/webvault.nix`
- `.local/nixpkgs/pkgs/servers/polaris/web.nix`
- `.local/nixpkgs/pkgs/tools/admin/meshcentral/default.nix` (yarn-based)

## Pitfalls and checks

- `npmDepsHash` must match lockfile state; update it after dependency changes.
- Avoid network downloads in build scripts; set environment flags when needed.
- Confirm output location (`dist`, `build`, workspace path) before writing `installPhase`.
