{ pkgs ? import <nixpkgs> {}, ... }: {
  pi = let
    version = "0.63.1";

    # Determine the architecture-specific file
    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "pi-darwin-arm64.tar.gz"
      else "pi-darwin-x64.tar.gz"
    else if pkgs.stdenv.isAarch64 then "pi-linux-arm64.tar.gz"
    else "pi-linux-x64.tar.gz";

    # Update sha256 as needed - use empty string "" and nix will tell you the correct one
    # nix-prefetch-url https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-darwin-arm64.tar.gz
    # nix-prefetch-url https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-darwin-x64.tar.gz
    # nix-prefetch-url https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-arm64.tar.gz
    # nix-prefetch-url https://github.com/badlogic/pi-mono/releases/download/v${version}/pi-linux-x64.tar.gz
    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-ZW5UfnWIlyCdPIlD9eUTKlnx7Ai3IvBdkcgeLW0bvgo="
      else "sha256-kJBNmxqQfNFkeB9Hb+RjzDJI0av2/bBwj7pO16yRwFc="
    else if pkgs.stdenv.isAarch64 then "sha256-h5sZZjlK7yLSP7VCtVOk36iuglrCtbNtzOolPzO5iWw="
    else "sha256-ow0KL7b8KBhXyI6rsTo8KldnjQxvdZjWQRDNXq0zX4g=";

    src = pkgs.fetchurl {
      url = "https://github.com/badlogic/pi-mono/releases/download/v${version}/${archFile}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
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
      homepage = "https://github.com/badlogic/pi-mono";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ ];
    };

    passthru.updateScript = ./update.sh;
  };
}
