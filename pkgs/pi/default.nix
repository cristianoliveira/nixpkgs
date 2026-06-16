{ pkgs ? import <nixpkgs> { }, ... }: {
  pi =
    let
      version = "0.79.4";

      # Determine the architecture-specific file
      archFile =
        if pkgs.stdenv.isDarwin then
          if pkgs.stdenv.isAarch64 then "pi-darwin-arm64.tar.gz"
          else "pi-darwin-x64.tar.gz"
        else if pkgs.stdenv.isAarch64 then "pi-linux-arm64.tar.gz"
        else "pi-linux-x64.tar.gz";

      # Update sha256 as needed - use empty string "" and nix will tell you the correct one
      # nix-prefetch-url https://github.com/earendil-works/pi/releases/download/v${version}/pi-darwin-arm64.tar.gz
      # nix-prefetch-url https://github.com/earendil-works/pi/releases/download/v${version}/pi-darwin-x64.tar.gz
      # nix-prefetch-url https://github.com/earendil-works/pi/releases/download/v${version}/pi-linux-arm64.tar.gz
      # nix-prefetch-url https://github.com/earendil-works/pi/releases/download/v${version}/pi-linux-x64.tar.gz
      sha256 =
        if pkgs.stdenv.isDarwin then
          if pkgs.stdenv.isAarch64 then "sha256-j7lAFbNnw78ud6W1i8xDKMCkh62DDh6uqRlcZlu0wsk="
          else "sha256-rBFV8zfBl9StiyrcDHgpnhfkBzXlgr8BtWLC2Gu/ONk="
        else if pkgs.stdenv.isAarch64 then "sha256-94pRRa2En7xYHe52izcNrjbNtPRE/KZESo1+FGO7vLU="
        else "sha256-ivkhO5LAQFibti9ALGuE0PXdXOByhYa3FVbYEGGXfao=";

      src = pkgs.fetchurl {
        url = "https://github.com/earendil-works/pi/releases/download/v${version}/${archFile}";
        inherit sha256;
      };
    in
    pkgs.stdenv.mkDerivation {
      pname = "pi";
      inherit version src;

      nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.autoPatchelfHook ];

      buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
        pkgs.stdenv.cc.cc.lib
      ];

      sourceRoot = ".";

      unpackPhase = ''
        runHook preUnpack
        tar xzf ${src}
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        # Copy entire pi directory to share
        mkdir -p $out/share
        cp -r pi $out/share/
        # Create bin symlink
        mkdir -p $out/bin
        ln -sf $out/share/pi/pi $out/bin/pi
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Pi AI coding assistant";
        homepage = "https://github.com/earendil-works/pi";
        license = licenses.mit;
        platforms = platforms.unix;
        maintainers = [ ];
      };

      passthru.updateScript = ./update.sh;
    };
}
