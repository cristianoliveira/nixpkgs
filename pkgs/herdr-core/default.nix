pkgs:
let
  inherit (pkgs) lib stdenv;
  system = stdenv.hostPlatform.system;
  artifacts = {
    aarch64-linux = { target = "linux-aarch64"; hash = "sha256-zzM5PPlQu3Y3NNw+FmEKudr4SSORpO8N5WAmzX91KFM="; };
    x86_64-linux = { target = "linux-x86_64"; hash = "sha256-Wy+Xy0sqnXprLMWUJiggPtn7t8wMK0sJrYpvVkjiRrc="; };
    aarch64-darwin = { target = "macos-aarch64"; hash = "sha256-d9ivCS4lrmUPRCTW2tJ1FPaRahHYB/sHUoWM0nwh5Pw="; };
    x86_64-darwin = { target = "macos-x86_64"; hash = "sha256-FaErgOk+xOB029uC+opm5SmFer+9+0VvlNURbcQ4/tw="; };
  };
  artifact = artifacts.${system} or (throw "herdr-core: unsupported system ${system}");
in
{
  herdr-core = stdenv.mkDerivation rec {
    pname = "herdr-core";
    version = "0.1.18";
    src = pkgs.fetchurl {
      url = "https://releases.herdr.dev/core/${version}/herdr-core-${artifact.target}.tar.gz";
      inherit (artifact) hash;
    };
    sourceRoot = ".";
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      ${if stdenv.isDarwin then ''
        mkdir -p "$out/Applications"
        cp -R "Herdr Core.app" "$out/Applications/"
        ln -s "$out/Applications/Herdr Core.app/Contents/MacOS/herdr-core" "$out/bin/herdr-core"
      '' else ''
        install -m755 herdr-core "$out/bin/herdr-core"
      ''}
      ln -s herdr-core "$out/bin/hc"
      runHook postInstall
    '';
    meta = {
      description = "Persistent terminal and agent runtime for Herdr";
      homepage = "https://github.com/herdrdev/herdr-core";
      license = lib.licenses.asl20;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = builtins.attrNames artifacts;
      mainProgram = "herdr-core";
    };
  };
}
