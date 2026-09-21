# Beads issue tracker and task management
pkgs: {
  beads = let
    version = "1.3.0";

    hashes = {
      darwin = {
        aarch64 = "sha256-fMdzZ9C4TFAkOhEIvB9zZIaZIRJX1BS5F1QL+Gjmu4U=";
        amd64 = "sha256-39imkYvCpYoNvHJ/fkA5dm4yPfoV5MyrJQ1kCFHikNU=";
      };
      linux = {
        aarch64 = "sha256-TOlEamjtwTICt2yEpH1m+z2tJ4e2RkyVIqEI+vnBxgg=";
        amd64 = "sha256-L5K5BOzzW2B+RNxcOSKRc69pxU8Rg+jXCfF3NUDNzzs=";
      };
    };

    # Determine the architecture-specific file
    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "beads_${version}_darwin_arm64.tar.gz"
      else "beads_${version}_darwin_amd64.tar.gz"
    else if pkgs.stdenv.isAarch64 then "beads_${version}_linux_arm64.tar.gz"
    else "beads_${version}_linux_amd64.tar.gz";

    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then hashes.darwin.aarch64
      else hashes.darwin.amd64
    else if pkgs.stdenv.isAarch64 then hashes.linux.aarch64
    else hashes.linux.amd64;

    src = pkgs.fetchurl {
      url = "https://github.com/steveyegge/beads/releases/download/v${version}/${archFile}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "beads";
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
      cp bd $out/bin/bd
      chmod +x $out/bin/bd
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Beads issue tracker and task management";
      homepage = "https://github.com/steveyegge/beads";
      license = licenses.mit;
      mainProgram = "bd";
      platforms = platforms.unix;
      maintainers = [ ];
    };

    passthru.updateScript = ./update.sh;
  };
}
