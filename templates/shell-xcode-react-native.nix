{ pkgs ? import <nixpkgs> {} }:
  # NOTE: when using mkShell nix clang is injected in the path
  # See: https://archive.ph/SRI5v
  # pkgs.mkShell {
  pkgs.mkShellNoCC {
    buildInputs = with pkgs; [
      # React Native
      nodejs

      (pnpm.override { nodejs = nodejs; })

      # For osx: arch -arm64 brew install --cask android-studio
      # android-studio
      sdkmanager

      # cocoapods

      # Xcode
      # darwin.xcode_16
      # This allow to use the Xcode installed in your system
      # To check this run: `which clang` it must come from `/nix/store/**xcode-wrapper**/bin/clang`
      (pkgs.xcodeenv.composeXcodeWrapper {
        # Download the Xcode version you need from the App Store and fill the field below
        versions = [ "16.3" ];
        xcodeBaseDir = "/Applications/Xcode.app";
      })
    ];

    shell = pkgs.zsh;
  }
