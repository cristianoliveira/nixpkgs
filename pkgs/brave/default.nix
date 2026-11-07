pkgs: {
  brave = pkgs.callPackage ((import ./make-brave.nix) ((import ./release.nix) // {
    optStem = "brave";
    fileStem = "brave-browser";
    appIdStem = "com.brave.Browser";
    darwinStem = "Brave Browser";
    changelogFile = "CHANGELOG_DESKTOP.md";
    homepage = "https://brave.com/";
    innerBinary = "brave";
  })) { };
}
