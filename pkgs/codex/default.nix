# Codex code agent
pkgs: {
  codex =
    let
      # NOTE: Update this version as needed and adjust sha256 accordingly
      # If you are not sure about the sha256, just use empty string ""
      # and nix will tell you the correct one
      version = "0.155.1"; # v0.155.1
      # Determine the architecture-specific URL
      arch =
        if pkgs.stdenv.isDarwin then
          if pkgs.stdenv.isAarch64 then "aarch64-apple-darwin"
          else "x86_64-apple-darwin"
        else if pkgs.stdenv.isAarch64 then "aarch64-unknown-linux-musl"
          else "x86_64-unknown-linux-musl";

      sha256 =
        if pkgs.stdenv.isDarwin then
          if pkgs.stdenv.isAarch64 then "sha256-lnkntHrElsKLOFdbl6kUQrA0o1DlDxU9Uab/o6eoF10="
          else "sha256-KHgh5NHpig/gt862GGHM+INcso2k3FrDoD+yPowQU2M="
        else if pkgs.stdenv.isAarch64 then "sha256-eeJbFN8Cto1JM6ATOeA3Alj1QwbgyeQtvmMRk6JKy2M="
        else "sha256-QtBhGsMx6jJMND+rrd4w0FAYr5onBVd2Wu73r+Ao9+s=";

      src = pkgs.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${arch}.zst";
        inherit sha256;
      };
    in
    pkgs.stdenv.mkDerivation {
      pname = "codex";
      inherit version;

      nativeBuildInputs = [ pkgs.zstd ];

      # Skip default unpack phase since we're handling a single compressed file
      dontUnpack = true;

      buildPhase = ''
        runHook preBuild
        zstd -d ${src} -o codex
        chmod +x codex
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp codex $out/bin/codex
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Codex code agent";
        homepage = "https://github.com/openai/codex";
        license = licenses.mit;
        platforms = platforms.all;
        maintainers = [ ];
      };
    };
}
