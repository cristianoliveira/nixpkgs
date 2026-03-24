# My NUR Nixpkgs

This repo contains a set of nix packages that are distributed via flake.nix

## Adding new packages

- Check other packages that have a similar stack the one you want to add
- Use the https://github.com/NixOS/nixpkgs as an inspiration. It is the main NixOS package repositories with more tha 100k packages.
  - Usually the user has it cloned in .tmp/repos/nixpkgs

## Landing the plane

IMPORTANT: Before completing your work check if the packages are working:

 - Make sure all the packages nix files are staged to git
 - Run: `nix run .#<mypackage> -- --help`
 - It should present the help for that cli
 - Run: `nix flake check`
