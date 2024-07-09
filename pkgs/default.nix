{ pkgs ? import <nixpkgs> {} }:
{
  ergoProxyNightly = pkgs.callPackage ./ergo-proxy-nightly.nix { };
  ergoProxy = pkgs.callPackage ./ergo-proxy.nix {};
  funzzy = pkgs.callPackage ./funzzy.nix {};
  fzz = pkgs.callPackage ./funzzy.nix {};
}
