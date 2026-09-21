# CLI for Confluence
pkgs: {
  confluence-cli = let
    version = "2.24.0";
    src = pkgs.fetchFromGitHub {
      owner = "pchuri";
      repo = "confluence-cli";
      rev = "v${version}";
      # Update sha256 as needed - use empty string "" and nix will tell you the correct one
      # nix-prefetch-url https://github.com/pchuri/confluence-cli/archive/refs/tags/v${version}.tar.gz
      sha256 = "sha256-vwRpQgL56Wo+z7sN3EpKHgdNNMM07SRbcQTyy0ptKVA=";
    };
  in pkgs.buildNpmPackage {
    pname = "confluence-cli";
    inherit version src;
    npmDepsHash = "sha256-bGm7LIJMl6JBfKJEcT5kh5jGmKYieB6uwlXe3uLgcKo=";
    dontNpmBuild = true;
    npmPackFlags = [ "--ignore-scripts" ];
    meta = with pkgs.lib; {
      description = "CLI for Confluence";
      homepage = "https://github.com/pchuri/confluence-cli";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ cristianoliveira ];
    };
  };
}
