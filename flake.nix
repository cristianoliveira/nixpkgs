{
  description = "Cristian Oliveira's packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";

    sway-setter.url = "github:cristianoliveira/sway-setter";
    funzzy.url = "github:cristianoliveira/funzzy";
    ergo.url = "github:cristianoliveira/ergo";
    snipgpt.url = "github:cristianoliveira/snipgpt";
  };

  outputs = { 
    nixpkgs,
    utils,
    sway-setter,
    funzzy,
    ergo,
    snipgpt,
    ... 
  }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        swaysetterPkgs = import sway-setter { inherit pkgs; };
        funzzyPkgs = import funzzy { inherit pkgs; };
        ergoPkgs = import ergo { inherit pkgs; };
        snipgptPkgs = import snipgpt { inherit pkgs; };
      in {
        packages = {
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

          # Snipgpt packages
          snipgpt = snipgptPkgs;
        };
    });
}
