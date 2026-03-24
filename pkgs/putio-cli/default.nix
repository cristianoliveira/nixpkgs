# putio-cli - Agent-first CLI for put.io API
pkgs: {
  putio-cli = let
    version = "1.0.7";
  in pkgs.stdenv.mkDerivation rec {
    pname = "putio-cli";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "putdotio";
      repo = "putio-cli";
      rev = "v${version}";
      hash = "sha256-6GfGlpXJaKZTk2oisN0pcowlo0HS3UQPbs+BQf8nPJY=";
    };

    pnpmDeps = pkgs.fetchPnpmDeps {
      pname = "putio-cli";
      inherit version src;
      fetcherVersion = 1;
      hash = "sha256-ZN6/0FtBvdvUsEnEiok0eDtlxhFOweuXE8ZcdvckpL4=";
    };

    nativeBuildInputs = [
      pkgs.makeBinaryWrapper
      pkgs.nodejs_24
      pkgs.pnpm
      pkgs.pnpm.configHook
    ];

    buildPhase = ''
      runHook preBuild
      pnpm install --offline
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/libexec/putio-cli
      cp -r dist package.json node_modules $out/libexec/putio-cli/
      makeWrapper ${pkgs.nodejs_24}/bin/node $out/bin/putio \
        --add-flags "$out/libexec/putio-cli/dist/bin.mjs" \
        --set NODE_PATH "$out/libexec/putio-cli/node_modules"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Agent-first CLI for put.io API";
      homepage = "https://github.com/putdotio/putio-cli";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ ];
      mainProgram = "putio";
    };
  };
}
