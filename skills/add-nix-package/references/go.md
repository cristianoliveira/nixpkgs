# Go Pattern (`buildGoModule`)

## When to use

- The project is written in Go and built with Go modules.
- You want a single CLI binary from source.

## Typical helpers and fields

- Helper: `buildGoModule`
- Source: `fetchFromGitHub` or `fetchgit`
- Common fields: `pname`, `version`, `src`, `vendorHash`, `ldflags`, `doCheck`, `meta.mainProgram`

## Minimal snippet

```nix
{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "my-go-cli";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "org";
    repo = "my-go-cli";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  vendorHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  ldflags = [ "-s" "-w" "-X main.version=${version}" ];

  meta = with lib; {
    description = "Example Go CLI";
    license = licenses.mit;
    mainProgram = "my-go-cli";
  };
}
```

## Real examples in `.local/nixpkgs/*`

- `.local/nixpkgs/pkgs/tools/networking/q/default.nix`
- `.local/nixpkgs/pkgs/tools/security/trufflehog/default.nix`

## Pitfalls and checks

- `vendorHash` mismatch is common after version updates; refresh it intentionally.
- Set `doCheck = false` only when tests are network-dependent or flaky in sandbox.
- Ensure `meta.mainProgram` matches the installed binary name.
