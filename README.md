# [C]ristian [O]liveira nixpkgs
[![periodic nixbuild](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-schedule-nixbuild.yml/badge.svg)](https://github.com/cristianoliveira/nixpkgs/actions/workflows/on-schedule-nixbuild.yml)

My collection of packages distributed as a nix flake.

## Usage

Using nix flakes
```sh
{
  description = "My ergo nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    conixpkgs = {
      url = "github:cristianoliveira/nixpkgs";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, conixpkgs, ... }:
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ config, pkgs, ... }: {
         # Injects conixpkgs into nixpkgs as "co"
         # and then can be referenced as `pkgs.co.ergo`
         nixpkgs.overlays = [ conixpkgs.overlays.default ];
        })

        # Exemple of installing a package from conixpkgs
        ({ config, pkgs, ... }: {
          environment.systemPackages = [
            pkgs.co.funzzy
          ];
        })
      ];
    };
  };
}
```

### Packages

See [Personal packages](./flake.nix) for a list of my personal packages.
See [External packages](./pkgs) for a list of OSS packages.
