# CLI for Confluence
pkgs: {
  confluence-cli = let
    version = "1.33.2";
    src = pkgs.fetchFromGitHub {
      owner = "pchuri";
      repo = "confluence-cli";
      rev = "v${version}";
      # Update sha256 as needed - use empty string "" and nix will tell you the correct one
      # nix-prefetch-url https://github.com/pchuri/confluence-cli/archive/refs/tags/v${version}.tar.gz
      sha256 = "sha256-P9eqTfKYFNFtMmpONDnjw9NlTj/OiihUoNpLDUIX4lg=";
    };
  in pkgs.buildNpmPackage {
    pname = "confluence-cli";
    inherit version src;
    npmDepsHash = "sha256-xSqo4+rC+OK+uIi+1pWeL+e1FiwFfwNUI9IDNRVtq/U=";
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
