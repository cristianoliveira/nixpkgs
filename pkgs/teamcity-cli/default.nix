# teamcity-cli - TeamCity from your terminal
pkgs: {
  teamcity-cli = let
    version = "0.9.0";

    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "teamcity_${version}_darwin_arm64.tar.gz"
      else "teamcity_${version}_darwin_x86_64.tar.gz"
    else if pkgs.stdenv.isAarch64 then "teamcity_${version}_linux_arm64.tar.gz"
    else "teamcity_${version}_linux_x86_64.tar.gz";

    # nix-prefetch-url https://github.com/JetBrains/teamcity-cli/releases/download/v0.9.0/teamcity_0.9.0_darwin_arm64.tar.gz
    # nix-prefetch-url https://github.com/JetBrains/teamcity-cli/releases/download/v0.9.0/teamcity_0.9.0_darwin_x86_64.tar.gz
    # nix-prefetch-url https://github.com/JetBrains/teamcity-cli/releases/download/v0.9.0/teamcity_0.9.0_linux_arm64.tar.gz
    # nix-prefetch-url https://github.com/JetBrains/teamcity-cli/releases/download/v0.9.0/teamcity_0.9.0_linux_x86_64.tar.gz
    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-p17lM8TER5Cd2U+zMABbTKOXNQYHuUK65TEG97hSmh4="
      else "sha256-9SfpZHogGLJfAq/Ame5dII6bMBmbDLLSSBaPT17Dlnc="
    else if pkgs.stdenv.isAarch64 then "sha256-ufzVGrn25iP+ww2UmjRfFoBYqB1BLdPMMjGoA5fd9YE="
    else "sha256-tTSAIF/hrOQy7KlFttEV2n/RkmGY+mpHWymU9Jhl/vY=";

    src = pkgs.fetchurl {
      url = "https://github.com/JetBrains/teamcity-cli/releases/download/v${version}/${archFile}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "teamcity-cli";
    inherit version;

    nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];

    sourceRoot = ".";

    unpackPhase = ''
      runHook preUnpack
      tar xzf ${src}
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp teamcity $out/bin/teamcity
      chmod +x $out/bin/teamcity
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "TeamCity from your terminal – builds, logs, agents, agent terminals, queues";
      homepage = "https://github.com/JetBrains/teamcity-cli";
      license = licenses.asl20;
      platforms = platforms.unix;
      maintainers = [ ];
      mainProgram = "teamcity";
    };
  };
}
