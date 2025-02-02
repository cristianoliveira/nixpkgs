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
         nixpkgs.overlays = [ 
            (final: prev: { co = import conixpkgs { inherit pkgs; }; })
          ];
        })

        # Exemplo of installing a package from conixpkgs
        ({ config, pkgs, ... }: {
          environment.systemPackages = [
            pkgs.co.ergoProxy
            pkgs.co.funzzy
          ];
        })
      ];
    };
  };
}
```

## Packages available

- [ergo](https://github.com/cristianoliveira/ergo) - A reverse proxy agent for local domain management add subdomains to localhost
- [funzzy](https://github.com/cristianoliveira/funzzy) - A lightweight watcher that runs command when files change.
- [sway-setter](https://github.com/cristianoliveira/sway-setter) - A cli for loading sway configurations
