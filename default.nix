{ pkgs ? import <nixpkgs> {} }:
{
  ergo = pkgs.callPackage ./ergo.nix {};
  funzzy = pkgs.callPackage ./funzzy.nix {};
}
