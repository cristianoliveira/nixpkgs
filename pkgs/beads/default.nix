# Beads issue tracker and task management
pkgs: {
  beads = let
    version = "0.56.1";

    hashes = {
      darwin = {
        aarch64 = "sha256-qopDCd4quMJ6kMA7ZSztxTpFiApclM1liBAG2jwvCBI=";
        amd64 = "sha256-yYeQFnfph4TrJNJhO5tU4HlSZJetedzlxvE2TPzMhRs=";
      };
      linux = {
        aarch64 = "sha256-pphWD0MoGdkdRThgpti8N7fTj5AbRLDTDVPPazlLm9A=";
        amd64 = "sha256-T59sxERloRYT/1KQCZAeqvhBxrH5HBXgArDs2iAVoVw=";
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
