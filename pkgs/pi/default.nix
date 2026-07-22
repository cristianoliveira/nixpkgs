{ pkgs ? import <nixpkgs> { }, ... }: {
  pi =
    let
      version = "0.81.1";

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
          if pkgs.stdenv.isAarch64 then "sha256-okg0AZ7ALuWkdf8cWl6fg4l0GRumrcQ0j25kdafHZns="
          else "sha256-7K7Q7w/K7/LkdSlPw0stfeRwBDSrnfI82w//2c+t9bg="
        else if pkgs.stdenv.isAarch64 then "sha256-wEnhMshUZiJNV9GfeSSQmwwP28m+2OCR3cNhgwcEs5I="
        else "sha256-H24j2ewGaKE86px4bj1Uwfxnm44i5/a/reA0n0gHy/I=";

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
