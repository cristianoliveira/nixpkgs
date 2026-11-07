pkgs:
let
  inherit (pkgs) lib stdenv;
  system = stdenv.hostPlatform.system;
  platforms = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
  builds = {
    aarch64-linux = { name = "herdr-linux-aarch64"; hash = "sha256-F9dTby2lCFlSNoDvJ53/ysjkojX05G/o2mwuxEFBiXw="; };
    x86_64-linux = { name = "herdr-linux-x86_64"; hash = "sha256-FNnovItKngEY13wyJm921GHwm0A0LrI3UpYL2J9Zkp0="; };
    aarch64-darwin = { name = "herdr-macos-aarch64"; hash = "sha256-+3fCIyoFqANUITgsiUOS9BdOTjihjkivPdApAVfDp+I="; };
    x86_64-darwin = { name = "herdr-macos-x86_64"; hash = "sha256-X7CpCOx/Z0Xj4kVziwa/rVbEY5HDkas8CVX76tAfE2k="; };
  };
  artifact = builds.${system} or (throw "herdr: unsupported system ${system}");
in
{
  herdr = stdenv.mkDerivation rec {
    pname = "herdr";
    version = "0.9.5";
    src = pkgs.fetchurl {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/${artifact.name}";
      inherit (artifact) hash;
    };
    dontUnpack = true;
    dontStrip = stdenv.isDarwin;
    nativeBuildInputs = lib.optionals stdenv.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = lib.optionals stdenv.isLinux [ stdenv.cc.cc.lib ];
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/herdr"
      runHook postInstall
    '';
    meta = {
      description = "Runtime for coding agents and their terminals";
      homepage = "https://github.com/herdrdev/herdr";
      license = lib.licenses.asl20;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      inherit platforms;
      mainProgram = "herdr";
    };
  };
}
