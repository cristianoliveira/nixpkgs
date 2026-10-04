{ lib, stdenv, fetchurl }:

let
  version = "0.4.0";
  archive = if stdenv.hostPlatform.isAarch64 then "darwin-arm64" else "darwin-amd64";
  hash = if stdenv.hostPlatform.isAarch64 then
    "sha256-WgaL6vxKIeFZ3IqcsN/lTtDAXkfx72Ecrw2919649J4="
  else
    "sha256-zuHlpHlYhxG5CpWkvD8BTsrttWrrnh3ulHTL6GOc9Bc=";
in
stdenv.mkDerivation {
  pname = "aerospace-gestures";
  inherit version;

  src = fetchurl {
    url = "https://github.com/cristianoliveira/aerospace-gestures/releases/download/v${version}/aerospace-gestures-v${version}-${archive}.tar.gz";
    inherit hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 aerospace-gestures $out/bin/aerospace-gestures
    runHook postInstall
  '';

  meta = {
    description = "Map macOS trackpad gestures to commands";
    homepage = "https://github.com/cristianoliveira/aerospace-gestures";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "aerospace-gestures";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
