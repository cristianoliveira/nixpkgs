{ pkgs ? import <nixpkgs> {} }:
{
  ergo = pkgs.callPackage ./ergo.nix {};
}
