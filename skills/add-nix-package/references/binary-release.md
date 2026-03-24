# Binary Release Pattern (`stdenv.mkDerivation`)

## When to use

- Upstream ships prebuilt release archives and source builds are impractical.
- You need per-platform URL/hash selection.

## Typical helpers and fields

- Helper: `stdenv.mkDerivation` (or `stdenvNoCC.mkDerivation`)
- Sources: `fetchurl`, often with a platform map in `data.nix`
- Common fields: `src`/`srcs`, `postUnpack`, `nativeBuildInputs`, `installPhase`, `meta.platforms`, `meta.sourceProvenance`

## Minimal snippet

```nix
{ lib, stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "my-bin-tool";
  version = "1.2.3";

  src = fetchurl {
    url = "https://example.com/my-bin-tool-${version}-linux-amd64.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 my-bin-tool $out/bin/my-bin-tool
    runHook postInstall
  '';

  meta = with lib; {
    description = "Example binary release package";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.linux;
    mainProgram = "my-bin-tool";
  };
}
```

## Real examples in `.local/nixpkgs/*`

- `.local/nixpkgs/pkgs/tools/admin/pulumi-bin/default.nix`
- `.local/nixpkgs/pkgs/tools/admin/winbox/default.nix`

## Pitfalls and checks

- Linux binaries may need `autoPatchelfHook` and wrapped `LD_LIBRARY_PATH`.
- Keep platform-specific hashes explicit; avoid one source for all systems.
- Validate binary runs with `nix run .#<name> -- --help` on supported platforms.
