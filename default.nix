# keep this file to avoid nix error
# error: opening file '/nix/store/<hash>-source/default.nix': No such file or directory
{ pkgs ? import <nixpkgs> {} }: {}
