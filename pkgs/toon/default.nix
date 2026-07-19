# TOON CLI - Token-Oriented Object Notation
# https://github.com/toon-format/toon
#
# The published @toon-format/cli npm tarball ships pre-built dist/ + bin/.
# Its runtime deps (citty, consola, tokenx) are all leaf packages with no
# transitive deps, so node_modules is assembled directly from their tarballs.
pkgs: {
  toon = let
    version = "2.3.1";

    cli = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@toon-format/cli/-/cli-${version}.tgz";
      hash = "sha256-ne6EMjKo3eAyWHCa64h7H8KA8QpzhGbWYQX9pySamTk=";
    };

    citty = pkgs.fetchurl {
      url = "https://registry.npmjs.org/citty/-/citty-0.2.2.tgz";
      hash = "sha256-/pO4suJ8xOsQn9n09p8x5LKIe7uA9tQ6ixuZpKlxLQE=";
    };
    consola = pkgs.fetchurl {
      url = "https://registry.npmjs.org/consola/-/consola-3.4.2.tgz";
      hash = "sha256-2p/eAKfPi8AXBocrSzbkeRtr5eWjMwtTnHAqr1H7DnE=";
    };
    tokenx = pkgs.fetchurl {
      url = "https://registry.npmjs.org/tokenx/-/tokenx-1.3.0.tgz";
      hash = "sha256-B9+IUrsKV0Vd0iocD+GTWK7tNF1amjfzqyeiKI2tTV8=";
    };
  in pkgs.stdenv.mkDerivation {
    pname = "toon";
    inherit version;
    src = cli;

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = [ pkgs.nodejs ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/toon/node_modules $out/bin

      # CLI package: bin/toon.mjs imports ../dist/index.mjs
      cp -r bin dist package.json $out/lib/toon/

      # Runtime node_modules (each npm tarball extracts to ./package)
      mkdir -p $out/lib/toon/node_modules/citty
      tar -xzf ${citty} -C $out/lib/toon/node_modules/citty --strip-components=1
      mkdir -p $out/lib/toon/node_modules/consola
      tar -xzf ${consola} -C $out/lib/toon/node_modules/consola --strip-components=1
      mkdir -p $out/lib/toon/node_modules/tokenx
      tar -xzf ${tokenx} -C $out/lib/toon/node_modules/tokenx --strip-components=1

      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/toon \
        --add-flags "$out/lib/toon/bin/toon.mjs"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Token-Oriented Object Notation (TOON) CLI – JSON ↔ TOON conversion";
      homepage = "https://github.com/toon-format/toon";
      changelog = "https://github.com/toon-format/toon/releases/tag/v${version}";
      license = licenses.mit;
      mainProgram = "toon";
      platforms = platforms.unix;
    };
  };
}
