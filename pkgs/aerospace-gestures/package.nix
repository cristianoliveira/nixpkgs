{ lib, stdenv, fetchurl }:

let
  version = "0.1.0";
  archive = if stdenv.hostPlatform.isAarch64 then "darwin-arm64" else "darwin-amd64";
  hash = if stdenv.hostPlatform.isAarch64 then
    "sha256-f0YRx+NOQt0s9k9/r0neioDl4NMhLUMQ6t3VMA/vyqw="
  else
    "sha256-+2tTc9+XyUG+17jDE20W0Jx3re0GIU1MeMsx0WTtK8M=";
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
