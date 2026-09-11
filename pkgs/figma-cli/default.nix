# Agent-first CLI for the Figma API
pkgs: {
  figma-cli = let
    version = "0.1.0";
  in pkgs.buildGoModule {
    pname = "figma-cli";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "figma-cli";
      rev = "v${version}";
      hash = "sha256-/j5TbHD6Brj1BHvuNe4Qf6g7Zm8+PsWMl2o3/7D405c=";
    };

    vendorHash = "sha256-yN6RmmJD1ir+2LDnjMCySiiO31iE4jg/SuPp6FylrBw=";
    subPackages = [ "cmd/figma" ];
    proxyVendor = true;

    meta = with pkgs.lib; {
      description = "Agent-first CLI for the Figma API";
      homepage = "https://github.com/cristianoliveira/figma-cli";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ cristianoliveira ];
      mainProgram = "figma";
    };
  };
}
