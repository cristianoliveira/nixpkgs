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
      overlay = final: prev: {
        co = import (self + /pkgs) prev;
      };
      perSystem = utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          swaysetterPkgs = import sway-setter { inherit pkgs; };
          funzzyDarwin =
            if pkgs.stdenv.isDarwin
            then
              pkgs.darwin // {
                apple_sdk = pkgs.darwin.apple_sdk // {
                  frameworks = pkgs.darwin.apple_sdk.frameworks // {
                    CoreServices = pkgs.libiconv;
                  };
                };
              }
            else {
              apple_sdk.frameworks.CoreServices = pkgs.libiconv;
            };
          funzzyPkg = pkgs.callPackage (funzzy + /nix/package.nix) {
            darwin = funzzyDarwin;
            rustPlatform = pkgs.rustPlatform // {
              buildRustPackage = args:
                pkgs.rustPlatform.buildRustPackage (args // {
                  cargoHash = "sha256-n9UHyr7W4hrN0+2dsYAYqkP/uzBv74p5XHU0g2MReJY=";
                });
            };
          };
          funzzyNightlyPkg = pkgs.callPackage (funzzy + /nix/package-nightly.nix) {
            darwin = funzzyDarwin;
          };
          ergoPkgs = import ergo { inherit pkgs; };
          aerospaceScratchpad = import aerospace-scratchpad { inherit pkgs; };
          aerospaceMarks = import aerospace-marks { inherit pkgs; };

          # Import local packages from centralized pkgs/default.nix
          localPackages = import (self + /pkgs) pkgs;
        in {
          packages = {
            # Sway Setter packages
            sway-setter = swaysetterPkgs.default;

            # Funzzy packages
            funzzy = funzzyPkg;
            fzz = funzzyPkg;
            funzzyNightly = funzzyNightlyPkg;
            fzzNightly = funzzyNightlyPkg;

            # Ergo packages
            ergoProxy = ergoPkgs.default;
            ergoProxyNightly = ergoPkgs.nightly;

            # Aerospace packages
            aerospace-scratchpad = aerospaceScratchpad.default;
            aerospace-marks = aerospaceMarks.default;

            # Local NUR packages
          } // localPackages;
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
