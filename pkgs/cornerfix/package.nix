{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "cornerfix";
  version = "0-unstable-2026-05-16";

  src = fetchFromGitHub {
    owner = "makalin";
    repo = "CornerFix";
    rev = "e8320ed5fd925edf113417cb1810dbea514636d8";
    hash = "sha256-x0N7834Tuho8GL3ruKlW3HPJbSOXAMNPzsIdeToai+s=";
  };

  makeFlags = [
    "PREFIX=$(out)"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 build/libcornerfix.dylib $out/lib/cornerfix/libcornerfix.dylib
    install -Dm755 build/cornerfixctl $out/bin/cornerfixctl
    install -Dm755 build/cornerfix-inject $out/bin/cornerfix-inject

    install -Dm644 libcornerfix.dylib.blacklist $out/share/cornerfix/libcornerfix.dylib.blacklist
    install -Dm644 README.md $out/share/cornerfix/README.md
    install -Dm644 CLI.md $out/share/cornerfix/CLI.md
    install -Dm644 LOADER.md $out/share/cornerfix/LOADER.md
    install -Dm644 COMPATIBILITY.md $out/share/cornerfix/COMPATIBILITY.md
    install -Dm644 TESTING.md $out/share/cornerfix/TESTING.md
    cp -R examples $out/share/cornerfix/examples
    chmod +x $out/share/cornerfix/examples/*.sh

    mkdir -p $out/Applications
    cp -R build/CornerFixTestApp.app $out/Applications/

    runHook postInstall
  '';

  meta = {
    description = "Injected macOS window corner sharpener";
    homepage = "https://github.com/makalin/CornerFix";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "cornerfixctl";
    maintainers = [ ];
  };
}
