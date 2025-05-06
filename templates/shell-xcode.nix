{ pkgs ? import <nixpkgs> {} }: let
    xcode = pkgs.xcodeenv.composeXcodeWrapper { };
  in
  # NOTE: when using mkShell nix clang is injected in the path
  # pkgs.mkShell {
  pkgs.mkShellNoCC {
    buildInputs = with pkgs; [
      # React Native
      nodejs_20

      (pnpm_8.override { nodejs = nodejs_20; })

      # For osx: arch -arm64 brew install --cask android-studio
      # android-studio
      sdkmanager

      # Xcode
      # cocoapods
      # darwin.xcode_16
      xcode
    ];

    shell = pkgs.zsh;
  }
