# A lightweight file watcher
pkgs: {
  funzzy =
    let
      version = "1.5.0";
    in
    pkgs.rustPlatform.buildRustPackage rec {
      pname = "funzzy";
      inherit version;

      src = pkgs.fetchFromGitHub {
        owner = "cristianoliveira";
        repo = "funzzy";
        rev = "v${version}";
        hash = "sha256-3EHZvgHlM3ldX6SEyqGf6MZIrDFOLXbKTZnJNczT570=";
      };

      cargoHash = "sha256-n9UHyr7W4hrN0+2dsYAYqkP/uzBv74p5XHU0g2MReJY=";

      # When installing from source only run unit tests
      checkPhase = ''
        cargo test $UNIT_TEST --lib
      '';

      buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
        # nixpkgs removed legacy `darwin.apple_sdk_11_0` stubs.
        # funzzy only needs iconv symbols on macOS.
        pkgs.libiconv
      ];

      meta = with pkgs.lib; {
        description = "A lightweight watcher";
        homepage = "https://github.com/cristianoliveira/funzzy";
        changelog = "https://github.com/cristianoliveira/funzzy/releases/tag/${src.rev}";
        license = licenses.mit;
        maintainers = [ ];
        mainProgram = "funzzy";
        platforms = platforms.unix;
      };
    };

  funzzyNightly =
    let
      version = "88b89cb";
    in
    pkgs.rustPlatform.buildRustPackage rec {
      pname = "funzzy";
      inherit version;

      src = pkgs.fetchFromGitHub {
        owner = "cristianoliveira";
        repo = "funzzy";
        rev = version;
        hash = "sha256-ZbpZaAoUsHPPbBAOOLYvEJDy06WO0uDYnRF1+gEzB0Q=";
      };

      cargoHash = "sha256-m7qlL+ajw/rwIHQ7KAw7gI9QmpTBnxWEeTVRgrBOcl4=";

      buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
        pkgs.libiconv
      ];

      meta = with pkgs.lib; {
        description = "A lightweight watcher";
        homepage = "https://github.com/cristianoliveira/funzzy";
        changelog = "https://github.com/cristianoliveira/funzzy/releases";
        license = licenses.mit;
        maintainers = [ ];
        mainProgram = "funzzy";
        platforms = platforms.unix;
      };
    };
}
