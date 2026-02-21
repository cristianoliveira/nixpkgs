# Process manager for AI agents (and humans)
pkgs: {
  gob = let
    version = "2.2.2";

    # Determine the architecture-specific file
    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "gob_${version}_darwin_arm64.tar.gz"
      else "gob_${version}_darwin_amd64.tar.gz"
    else if pkgs.stdenv.isAarch64 then "gob_${version}_linux_arm64.tar.gz"
    else "gob_${version}_linux_amd64.tar.gz";

    # Update sha256 as needed - use empty string "" and nix will tell you the correct one
    # nix-prefetch-url https://github.com/juanibiapina/gob/releases/download/v2.2.2/gob_2.2.2_darwin_arm64.tar.gz
    # nix-prefetch-url https://github.com/juanibiapina/gob/releases/download/v2.2.2/gob_2.2.2_darwin_amd64.tar.gz
    # nix-prefetch-url https://github.com/juanibiapina/gob/releases/download/v2.2.2/gob_2.2.2_linux_arm64.tar.gz
    # nix-prefetch-url https://github.com/juanibiapina/gob/releases/download/v2.2.2/gob_2.2.2_linux_amd64.tar.gz
    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-/2OieYYH9y4s7DOrPWKhQa4jUHLwCSP5f1alxB7ucfA="
      else "sha256-7Yfs6qkAXRA6cjHdt8Xe8JgUKEzEXBwgruD/2dj4q1w="
    else if pkgs.stdenv.isAarch64 then "sha256-YZCn54r0bOn0yZqKuPmfu6IuYz4yg1w1ll8M2e1JeyM="
    else "sha256-mdLqKwvsh2YHMMpkpxHmpXbRnIUOOxoeW1LwCxHhXyE=";

    src = pkgs.fetchurl {
      url = "https://github.com/juanibiapina/gob/releases/download/v${version}/${archFile}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "gob";
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
      cp gob $out/bin/gob
      chmod +x $out/bin/gob
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Process manager for AI agents (and humans)";
      homepage = "https://github.com/juanibiapina/gob";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };
}
