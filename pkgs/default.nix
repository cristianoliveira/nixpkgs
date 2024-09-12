{ pkgs ? import <nixpkgs> {} }:
  let 
    funzzy = pkgs.callPackage ./funzzy.nix {};
    funzzyNightly = pkgs.callPackage ./funzzy-nightly.nix {};

    ergoProxyNightly = pkgs.callPackage ./ergo-proxy-nightly.nix { };
    ergoProxy = pkgs.callPackage ./ergo-proxy.nix {};
  in {
    # too many aliases
    funzzy = funzzy;
    fzz = funzzy;
    funzzyNightly = funzzyNightly;
    fzzNightly = funzzyNightly;
  }
