# nixpkgs

My collection of nix packages to install my packages on any machine.

## Usage

Using nix flakes
```sh
{
  description = "My ergo nix configuration";

  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs";
    mypkgs = {
      url = "github:cristianoliveira/nixpkgs";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, mypkgs, ... }:
  { 
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ config, pkgs, ... }: { 
         # Injects mypkgs into nixpkgs as custom
         # and then can be referenced as `pkgs.custom.ergo`
         nixpkgs.overlays = [ 
            (final: prev: { custom = import mypkgs { inherit pkgs; }; })
          ];
        })

        # Exemplo of installing a package from mypkgs
        ({ config, pkgs, ... }: {
          environment.systemPackages = [
            pkgs.custom.ergo
          ];
        })
      ];
    };
  };
}
```

## Packages available

- [ergo](https://github.com/cristianoliveira/ergo) - A reverse proxy agent for local domain management add subdomains to localhost
