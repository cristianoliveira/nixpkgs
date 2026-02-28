# On-device search engine for markdown notes, meeting transcripts, and knowledge bases
pkgs: {
  qmd = let
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "tobi";
      repo = "qmd";
      rev = "88f78314bb22bd23e68bf4d16a447323c2a29b0f";
      # Update sha256 as needed - use empty string "" and nix will tell you the correct one
      # nix-prefetch-url https://github.com/tobi/qmd/archive/refs/tags/v${version}.tar.gz
      sha256 = "sha256-ejJxsUW1KlUobNvweU0cCx224dvAb1jQUfGLrYeSNM8=";
    };
  in pkgs.stdenv.mkDerivation {
    pname = "qmd";
    inherit version src;

    dontStrip = true;

    nativeBuildInputs = [ pkgs.makeWrapper pkgs.bun ];
    buildInputs = [ pkgs.sqlite ];

    installPhase = ''
      mkdir -p $out/lib/qmd
      mkdir -p $out/bin

      cp -r src $out/lib/qmd/
      cp qmd $out/lib/qmd/
      cp package.json $out/lib/qmd/
      cp bun.lock $out/lib/qmd/

      makeWrapper ${pkgs.bun}/bin/bun $out/bin/qmd \
        --add-flags "--install" \
        --add-flags "$out/lib/qmd/src/qmd.ts" \
        --set DYLD_LIBRARY_PATH "${pkgs.sqlite.out}/lib" \
        --set LD_LIBRARY_PATH "${pkgs.sqlite.out}/lib"
    '';

    meta = with pkgs.lib; {
      description = "On-device search engine for markdown notes, meeting transcripts, and knowledge bases";
      homepage = "https://github.com/tobi/qmd";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };
}
