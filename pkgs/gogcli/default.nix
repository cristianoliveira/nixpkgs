# gogcli - Claude Code native browser extension and iOS app integration
pkgs: {
  gogcli = let
    version = "0.40.0";

    # Determine the architecture-specific file
    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "gogcli_${version}_darwin_arm64.tar.gz"
      else "gogcli_${version}_darwin_amd64.tar.gz"
    else if pkgs.stdenv.isAarch64 then "gogcli_${version}_linux_arm64.tar.gz"
    else "gogcli_${version}_linux_amd64.tar.gz";

    # nix-prefetch-url https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_darwin_arm64.tar.gz
    # nix-prefetch-url https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_darwin_amd64.tar.gz
    # nix-prefetch-url https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_linux_arm64.tar.gz
    # nix-prefetch-url https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_linux_amd64.tar.gz
    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-SNEejpXAd6SylbeLDNM8kzSbkqLwM3ys4q/y3RqKwH4="
      else "sha256-uVPYioTPml2B9fMb12t2uTBIOhuByVdCOQZfe1UZoyA="
    else if pkgs.stdenv.isAarch64 then "sha256-IcqXV/Z6VzEVtReFQYRWHO9rO3PCHg9gxyIpUixxmKw="
    else "sha256-X3OBWVDzDeQWW3t2cQPKRcSVDoSh2mAe2lKU6f+U92c=";

    src = pkgs.fetchurl {
      url = "https://github.com/steipete/gogcli/releases/download/v${version}/${archFile}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "gogcli";
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
      cp gog $out/bin/gog
      chmod +x $out/bin/gog
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Claude Code native browser extension and iOS app integration CLI";
      homepage = "https://github.com/steipete/gogcli";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ ];
      mainProgram = "gog";
    };
  };
}
