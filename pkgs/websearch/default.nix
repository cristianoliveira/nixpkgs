# Multi-provider web search and content extraction CLI
pkgs: {
  websearch = let
    version = "2.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "websearch";
      rev = "fa1dd63fbaf4e4b58f8b3b8bab54b36094901772";
      # Update sha256 as needed - use empty string "" and nix will tell you the correct one
      # nix-prefetch-url https://github.com/cristianoliveira/websearch/archive/<rev>.tar.gz
      sha256 = "sha256-6XmGg+lwWPYeFS5kbW5b1i9FojgocxNY2dpZwGA2tYM=";
    };
  in pkgs.buildNpmPackage {
    pname = "websearch";
    inherit version src;

    npmDepsHash = "sha256-RUwzPhCQ1Y4QHvigxQ1t5n5hHHWhjB0lFIH2MoZWTxw=";

    nativeBuildInputs = [ pkgs.makeWrapper ];

    # vite build bundles everything except jsdom/commander, which stay external
    # and must be resolvable from node_modules at runtime.
    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/websearch
      cp -r dist $out/lib/websearch/
      cp -r node_modules $out/lib/websearch/

      makeWrapper "${pkgs.lib.getExe pkgs.nodejs}" "$out/bin/websearch" \
        --add-flags "$out/lib/websearch/dist/websearch.js"

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Multi-provider web search and content extraction CLI";
      homepage = "https://github.com/cristianoliveira/websearch";
      license = licenses.mit;
      platforms = platforms.unix;
      mainProgram = "websearch";
    };
  };
}
