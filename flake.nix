{
  description = "Cristian Oliveira's packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";

    sway-setter.url = "github:cristianoliveira/sway-setter";
  };

  outputs = { self, nixpkgs, utils, sway-setter, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        srcpkgs = import ./default.nix { inherit pkgs; };
        swaysetterPkgs = import sway-setter { inherit pkgs; };
      in {
        packages = srcpkgs // {
          sway-setter = swaysetterPkgs.default;
        };

        devShells.default = pkgs.callPackage ./shell.nix { inherit pkgs srcpkgs; };
    });
}
