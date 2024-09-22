{ pkgs ? import <nixpkgs> {} }:
  let 
    funzzy = pkgs.callPackage ./pkgs/funzzy.nix {};
    funzzyNightly = pkgs.callPackage ./pkgs/funzzy-nightly.nix {};
  in {
    # too many aliases
    funzzy = funzzy;
    fzz = funzzy;
    funzzyNightly = funzzyNightly;
    fzzNightly = funzzyNightly;

    ergoProxyNightly = pkgs.callPackage ./pkgs/ergo-proxy-nightly.nix { };
    ergoProxy = pkgs.callPackage ./pkgs/ergo-proxy.nix {};
  }
