{
  description = "Cristian Oliveira's packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";

    funzzy.url = "github:cristianoliveira/funzzy";
    sway-setter.url = "github:cristianoliveira/sway-setter";
  };

  outputs = { self, nixpkgs, utils, sway-setter, funzzy, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        srcpkgs = import ./default.nix { inherit pkgs; };
        swaysetterPkgs = import sway-setter { inherit pkgs; };
        funzzyPkgs = import funzzy { inherit pkgs; };
      in {
        packages = srcpkgs // {
          # Sway Setter packages
          sway-setter = swaysetterPkgs.default;

          # Funzzy packages
          funzzy = funzzyPkgs.default;
          fzz = funzzyPkgs.default;
          funzzyNightly = funzzyPkgs.nightly;
          fzzNightly = funzzyPkgs.nightly;
        };

        devShells.default = pkgs.callPackage ./shell.nix { inherit pkgs srcpkgs; };
    });
}
