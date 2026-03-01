{
  description = "Cristian Oliveira's packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";

    sway-setter.url = "github:cristianoliveira/sway-setter";
    funzzy.url = "github:cristianoliveira/funzzy";
    ergo.url = "github:cristianoliveira/ergo";
    snipgpt.url = "github:cristianoliveira/snipgpt";

    aerospace-scratchpad.url = "github:cristianoliveira/aerospace-scratchpad";
    aerospace-marks.url = "github:cristianoliveira/aerospace-marks";
  };

  outputs = {
    nixpkgs,
    utils,
    sway-setter,
    funzzy,
    ergo,
    snipgpt,
    aerospace-scratchpad,
    aerospace-marks,
    self,
    ...
  }:
    let
      mkCoPackages = pkgs:
        let
          swaysetterPkgs = import sway-setter { inherit pkgs; };
          funzzyPkgs = import funzzy { inherit pkgs; };
          ergoPkgs = import ergo { inherit pkgs; };
          aerospaceScratchpad = import aerospace-scratchpad { inherit pkgs; };
          aerospaceMarks = import aerospace-marks { inherit pkgs; };

          # Import local packages from centralized pkgs/default.nix
          localPackages = import (self + /pkgs) pkgs;
        in {
          # Sway Setter packages
          sway-setter = swaysetterPkgs.default;

          # Funzzy packages
          funzzy = funzzyPkgs.default;
          fzz = funzzyPkgs.default;
          funzzyNightly = funzzyPkgs.nightly;
          fzzNightly = funzzyPkgs.nightly;

          # Ergo packages
          ergoProxy = ergoPkgs.default;
          ergoProxyNightly = ergoPkgs.nightly;

          # Aerospace packages
          aerospace-scratchpad = aerospaceScratchpad.default;
          aerospace-marks = aerospaceMarks.default;

          # Local NUR packages
        } // localPackages;
      overlay = final: prev: {
        co = mkCoPackages final;
      };
      perSystem = utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          packages = mkCoPackages pkgs;
        });
    in
      perSystem // {
        overlays = { default = overlay; };
        lib = {
          withOverlays = system: overlays: import nixpkgs {
            inherit system;
            overlays = [ overlay ] ++ overlays;
          };
        };
      };
}
