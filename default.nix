{ pkgs ? import <nixpkgs> {} }:
{
  ergoProxyNightly = pkgs.callPackage ./pkgs/ergo-proxy-nightly.nix { };
  ergoProxy = pkgs.callPackage ./pkgs/ergo-proxy.nix {};
}
