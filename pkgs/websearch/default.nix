# Multi-provider web search and content extraction CLI
pkgs: {
  websearch = let
    version = "3.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "websearch";
      rev = "0fce90212cb26ab61422fc0c6761e7e779aa9512";
      # nix-prefetch-url https://github.com/cristianoliveira/websearch/archive/<rev>.tar.gz
      sha256 = "sha256-OVUkGAe5egrjmz5CRnhIJOQHMUYuiNGBTFW9C/6eaVk=";
    };
  in pkgs.buildNpmPackage {
    pname = "websearch";
    inherit version src;

    npmDepsHash = "sha256-wabg8wpCQExsV4u6LPEbgO/uq+w3AbXXnfH7U5n87UY=";

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
