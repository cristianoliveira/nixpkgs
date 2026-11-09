{ fetchFromGitHub
, lib
, swift
, swiftpm
, swiftPackages
, swiftpm2nix
}:

let
  version = "0.7.0-alpha.1";
  src = fetchFromGitHub {
    owner = "cristianoliveira";
    repo = "cafune";
    rev = "45762fa1e10f99dcdc71b07f2637dba813742b6d";
    hash = "sha256-o03Q8Hds6PKFgzAqKhLBdjO4OegTHCsrI7eW+UsCgaY=";
  };
  generated = swiftpm2nix.helpers "${src}/nix";
in
swiftPackages.stdenv.mkDerivation {
  pname = "cafune";
  inherit version src;

  nativeBuildInputs = [ swift swiftpm ];

  configurePhase = ''
    runHook preConfigure
    ${generated.configure}
    runHook postConfigure
  '';

  # The Nix Darwin SwiftPM toolchain does not provide Apple's xctest runner.
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$(swiftpmBinPath)/cafune" "$out/bin/cafune"
    runHook postInstall
  '';

  meta = {
    description = "Map macOS trackpad gestures to commands";
    homepage = "https://github.com/cristianoliveira/cafune";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "cafune";
  };
}
