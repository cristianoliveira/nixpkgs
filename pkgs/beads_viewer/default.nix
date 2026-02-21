# Beads viewer for visualizing beads data
pkgs: {
  beads_viewer = let
    version = "0.13.0";

    # Determine the architecture-specific file
    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "bv_${version}_darwin_arm64.tar.gz"
      else "bv_${version}_darwin_amd64.tar.gz"
    else if pkgs.stdenv.isAarch64 then "bv_${version}_linux_arm64.tar.gz"
    else "bv_${version}_linux_amd64.tar.gz";

    # Update sha256 as needed - use empty string "" and nix will tell you the correct one
    # nix-prefetch-url https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_darwin_arm64.tar.gz
    # nix-prefetch-url https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_darwin_amd64.tar.gz
    # nix-prefetch-url https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_linux_arm64.tar.gz
    # nix-prefetch-url https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_linux_amd64.tar.gz
    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-eCA/NKQ7QT9KEEOtBiwOb9ksxj2k202ENK1tWKOdCEY="
      else "sha256-n7+K0grNaNKDvrJurt25Ow3/2wuWVvrjp38fFWcPYfA="
    else if pkgs.stdenv.isAarch64 then "sha256-dxkewC884pA0exBZFixC2A+VgTw5ZyirnD8Zj9ncAwg="
    else "sha256-8Ux9Brf2u78ljmTB49EBXCAn41WssOl8c+dZ1DZDjkw=";

    src = pkgs.fetchurl {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/${archFile}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "beads-viewer";
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
      cp bv $out/bin/bv
      chmod +x $out/bin/bv
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Beads viewer for visualizing beads data";
      homepage = "https://github.com/Dicklesworthstone/beads_viewer";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };
}
