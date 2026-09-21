# Ferrite text editor
pkgs: {
  ferrite = let
    version = "0.3.0";

    filename = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "ferrite-macos-arm64.tar.gz"
      else "ferrite-macos-x64.tar.gz"
    else if pkgs.stdenv.isLinux then
      if pkgs.stdenv.isAarch64 then throw "Ferrite v${version} not available for aarch64-linux"
      else "ferrite-linux-x64.tar.gz"
    else throw "Ferrite v${version} unsupported platform";

    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-rXZHZnhwa/0ExNh03qf0BE3Z7OeEI0Rxfgk6oLuBK8Y=" else
      "sha256-PyTYZ8+1wUeLyE6buhRPK9dQdSixu3QyPO7M5T8+v6E="
    else if pkgs.stdenv.isLinux then
      if pkgs.stdenv.isAarch64 then throw "Ferrite v${version} not available for aarch64-linux"
      else "sha256-M4sgG/Bxco3bCLdGYAglfo4+cyXHF1hsv+XMXtzGPtg="
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
      if [ -x Ferrite.app/Contents/MacOS/ferrite ]; then
        cp Ferrite.app/Contents/MacOS/ferrite $out/bin/ferrite
      else
        cp ferrite $out/bin/ferrite
      fi
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
