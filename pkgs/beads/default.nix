# Beads issue tracker and task management
pkgs: {
  beads = let
    version = "0.49.0";

    # Determine the architecture-specific file
    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "beads_${version}_darwin_arm64.tar.gz"
      else "beads_${version}_darwin_amd64.tar.gz"
    else if pkgs.stdenv.isAarch64 then "beads_${version}_linux_arm64.tar.gz"
    else "beads_${version}_linux_amd64.tar.gz";

    # Update sha256 as needed - use empty string "" and nix will tell you the correct one
    # nix-prefetch-url https://github.com/steveyegge/beads/releases/download/v${version}/beads_${version}_darwin_arm64.tar.gz
    # nix-prefetch-url https://github.com/steveyegge/beads/releases/download/v${version}/beads_${version}_darwin_amd64.tar.gz
    # nix-prefetch-url https://github.com/steveyegge/beads/releases/download/v${version}/beads_${version}_linux_arm64.tar.gz
    # nix-prefetch-url https://github.com/steveyegge/beads/releases/download/v${version}/beads_${version}_linux_amd64.tar.gz
    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-6xJ7heheeaKWD+EqkGZVi/znQ579xsZpbe2Lzjozw+A="
      else "sha256-Z+Ovm8QsnYcbnp7zocmzYnoC2wuZRxT4RDnlqlENcxE="
    else if pkgs.stdenv.isAarch64 then "sha256-M5o2uqwta0+GBeamXNpKUZD9IMBtq8ncFrXSlOh7d+4="
    else "sha256-BOJdEYsoehdzizR+HIS0pWmOtcz9hKgC7RzUiyIMwe0=";

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
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };
}
