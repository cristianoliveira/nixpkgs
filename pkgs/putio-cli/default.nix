# putio-cli - Agent-first CLI for put.io API
pkgs: {
  putio-cli = let
    version = "1.0.10";
    pnpmHook = if pkgs ? pnpmConfigHook then pkgs.pnpmConfigHook else pkgs.pnpm.configHook;
    fetchPnpmDeps = if pkgs ? fetchPnpmDeps then pkgs.fetchPnpmDeps else pkgs.pnpm.fetchDeps;
  in pkgs.stdenv.mkDerivation rec {
    pname = "putio-cli";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "putdotio";
      repo = "putio-cli";
      rev = "v${version}";
      hash = "sha256-8H8DvXM4h37bPkhHARxxwTDZ+LhboF//crKuR5IUwr4=";
    };

    pnpmDeps = fetchPnpmDeps {
      pname = "putio-cli";
      inherit src;
      hash = "sha256-f9rP46GisZRKzYiUTb2vo6stcXLOO2IOkRhtvjXzcMI=";
      fetcherVersion = 1;
    };

    nativeBuildInputs = [
      pkgs.makeBinaryWrapper
      pkgs.nodejs_24
      pkgs.pnpm
      pnpmHook
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
