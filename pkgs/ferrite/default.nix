# Ferrite text editor
pkgs: {
  ferrite = let
    version = "0.2.3";

    filename = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "ferrite-macos-arm64.tar.gz"
      else "ferrite-macos-x64.tar.gz"
    else if pkgs.stdenv.isLinux then
      if pkgs.stdenv.isAarch64 then throw "Ferrite v${version} not available for aarch64-linux"
      else "ferrite-linux-x64.tar.gz"
    else throw "Ferrite v${version} unsupported platform";

    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-qKQRoPBq2lktZRQbh80xWR5CLljuv8h6aomVEPowBmg=" else
      "sha256-WxmHjMTr9ihtZVrzB/s31SZepAHGfEyoI5ItWGjH7oI="
    else if pkgs.stdenv.isLinux then
      if pkgs.stdenv.isAarch64 then throw "Ferrite v${version} not available for aarch64-linux"
      else "sha256-81HmxZalj3AsHdxq1AXmpwZchMklWLHnu1gwvIgL0RA="
    else throw "Ferrite v${version} unsupported platform";

    src = pkgs.fetchurl {
      url = "https://github.com/OlaProeis/Ferrite/releases/download/v${version}/${filename}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "ferrite";
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
      cp ferrite $out/bin/ferrite
      chmod +x $out/bin/ferrite
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Ferrite text editor";
      homepage = "https://github.com/OlaProeis/Ferrite";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };
}
