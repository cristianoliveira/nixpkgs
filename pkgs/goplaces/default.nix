# Modern Google Places CLI in Go
pkgs: {
  goplaces = let
    version = "0.3.0";

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
      if pkgs.stdenv.isAarch64 then "sha256-FAhLzN7CbMghXNTLPOyaRHJjMuUt+LlDoWRV0zQSpmU="
      else "sha256-Rue66IenX9MX69nAwDGDMSN5+2LzzeZ8nE7N2eCvR1E="
    else if pkgs.stdenv.isAarch64 then "sha256-IhwA/xN7SqdoNd7WB+RtOKHsmGyo+62IZDBEDWfevRs="
    else "sha256-z6eNTZo2K7wsPT/3d3Fg+1pZlN5+hSGwBIG3LUBTsec=";

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
