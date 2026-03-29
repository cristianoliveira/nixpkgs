# Nightly opencode package
# This file exports a function that takes pkgs and returns a set of nightly/custom packages
# Usage: nightly = (import ./nightly-pkgs.nix) prev;
#
# To update sha256 hashes:
# 1. Fetch hash: nix-prefetch-url https://github.com/openai/codex/releases/download/rust-v${version}/codex-${arch}.zst
# 2. Convert to SRI: nix hash convert --hash-algo sha256 <hash-from-step-1>
# Example for Darwin aarch64:
#   nix-prefetch-url https://github.com/openai/codex/releases/download/rust-v0.80.0/codex-aarch64-apple-darwin.zst
#   nix hash convert --hash-algo sha256 06wg50zymn83a8irbw67nir9ahn2vqszqjibcw8gzpw3r6ds5xpj
pkgs: {
  opencode = let
    version = "1.3.5";
    needsPatchelf = pkgs.stdenv.isLinux && !pkgs.stdenv.hostPlatform.isMusl;

    # Determine the architecture-specific file and URL
    # Linux logic matches install script: checks for musl and uses baseline for x64
    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "opencode-darwin-arm64.zip"
      else "opencode-darwin-x64.zip"
    else if pkgs.stdenv.isLinux then
      let
        arch = if pkgs.stdenv.isAarch64 then "arm64" else "x64";
        # Use baseline for x64 (no AVX2 requirement) for maximum compatibility
        baseline = if pkgs.stdenv.isAarch64 then "" else "-baseline";
        # Check for musl libc (Alpine Linux, NixOS with musl, etc.)
        musl = if pkgs.stdenv.hostPlatform.isMusl then "-musl" else "";
      in "opencode-linux-${arch}${baseline}${musl}.tar.gz"
    else throw "Unsupported platform";

    # Update sha256 as needed - use empty string "" and nix will tell you the correct one
    # Linux x64-baseline: nix-prefetch-url https://github.com/anomalyco/opencode/releases/download/v1.2.24/opencode-linux-x64-baseline.tar.gz
    # Linux x64-baseline-musl: nix-prefetch-url https://github.com/anomalyco/opencode/releases/download/v1.2.24/opencode-linux-x64-baseline-musl.tar.gz
    # Linux arm64: nix-prefetch-url https://github.com/anomalyco/opencode/releases/download/v1.2.24/opencode-linux-arm64.tar.gz
    # Linux arm64-musl: nix-prefetch-url https://github.com/anomalyco/opencode/releases/download/v1.2.24/opencode-linux-arm64-musl.tar.gz
    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then
        "sha256-csUqhq8TWpBC5P6Vfebs7ncX3LcSVqFCpwv2hgVo1HA="
      else
        "sha256-rwEFLuV/kAc9jlYso15T9obYiH4HnYFHoSYEZ8GjJwY="
    else if pkgs.stdenv.isLinux then
      if pkgs.stdenv.isAarch64 then
        if pkgs.stdenv.hostPlatform.isMusl then
          "sha256-GoI3JEv/aIcujtCv3SXlUAlRNyxDP2dUr/BGMpG5sdU="  # arm64-musl
        else
          "sha256-CjVtmU98gOTEqA5JGGgl0XK1jAwMm9AmK88gvk8CCIk="  # arm64
      else  # x64
        if pkgs.stdenv.hostPlatform.isMusl then
          "sha256-HlkJi8Of0c+WCELSLbC6TvAPUzqgdZ9haAX84dwUfv4="  # x64-baseline-musl
        else
          "sha256-Cy7duyl8obKVqJ14bQBpFf2p2oPnJMPY+h9i2Pfn1xI="  # x64-baseline
    else throw "Unsupported platform";

    src = pkgs.fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/${archFile}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "opencode";
    inherit version;

    nativeBuildInputs = (if pkgs.stdenv.isDarwin then [ pkgs.unzip ] else [ pkgs.gnutar pkgs.gzip ])
      ++ pkgs.lib.optionals needsPatchelf [ pkgs.autoPatchelfHook ];

    buildInputs = pkgs.lib.optionals needsPatchelf [
      pkgs.stdenv.cc.cc.lib
    ];

    # Don't strip the binary - it's built with Bun and stripping breaks it
    dontStrip = true;

    sourceRoot = ".";

    unpackPhase = if pkgs.stdenv.isDarwin then ''
      runHook preUnpack
      unzip ${src}
      runHook postUnpack
    '' else ''
      runHook preUnpack
      tar xzf ${src}
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp opencode $out/bin/opencode
      chmod +x $out/bin/opencode
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "OpenCode - AI-powered code editor";
      homepage = "https://github.com/anomalyco/opencode";
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };
}
