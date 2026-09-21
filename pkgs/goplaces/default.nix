# Modern Google Places CLI in Go
pkgs: {
  goplaces = let
    version = "0.4.11";

    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "goplaces_${version}_darwin_arm64.tar.gz"
      else "goplaces_${version}_darwin_amd64.tar.gz"
    else if pkgs.stdenv.isAarch64 then "goplaces_${version}_linux_arm64.tar.gz"
    else "goplaces_${version}_linux_amd64.tar.gz";

    # nix store prefetch-file https://github.com/steipete/goplaces/releases/download/v0.3.0/goplaces_0.3.0_darwin_arm64.tar.gz
    # nix store prefetch-file https://github.com/steipete/goplaces/releases/download/v0.3.0/goplaces_0.3.0_darwin_amd64.tar.gz
    # nix store prefetch-file https://github.com/steipete/goplaces/releases/download/v0.3.0/goplaces_0.3.0_linux_arm64.tar.gz
    # nix store prefetch-file https://github.com/steipete/goplaces/releases/download/v0.3.0/goplaces_0.3.0_linux_amd64.tar.gz
    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-k4eJbIGuxHBlEO/WDdlY+99QVuapaN3eoQrU+XI5QCg="
      else "sha256-WuGUDysXJKNToHFmQQ3v2kLAdqwej4KEyB3t6SleSsU="
    else if pkgs.stdenv.isAarch64 then "sha256-Rfwk7QDYk+7yGH6/9j4Vk/yyHLgqCTt67s142y4hpac="
    else "sha256-oLajAHaeUyECovZS+imBOibEVgjqQNg2/Zfq2Msl5lo=";

    src = pkgs.fetchurl {
      url = "https://github.com/steipete/goplaces/releases/download/v${version}/${archFile}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "goplaces";
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
      cp goplaces $out/bin/goplaces
      chmod +x $out/bin/goplaces
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Modern Google Places CLI in Go";
      homepage = "https://github.com/steipete/goplaces";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ ];
      mainProgram = "goplaces";
    };
  };
}
