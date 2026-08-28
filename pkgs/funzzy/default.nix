# A lightweight file watcher
pkgs: {
  funzzy =
    let
      version = "2.0.0";
    in
    pkgs.rustPlatform.buildRustPackage rec {
      pname = "funzzy";
      inherit version;

      src = pkgs.fetchFromGitHub {
        owner = "cristianoliveira";
        repo = "funzzy";
        rev = "v${version}";
        hash = "sha256-i/HtqI8VzYW7Mz8QlH/KF3uuJ6NH2fBmZBgKEV1jH+A=";
      };

      # Use importCargoLock instead of cargoHash/fetchCargoVendor: crates.io
      # rejects the concurrent vendor fetches used by fetchCargoVendor (HTTP 403).
      cargoLock.lockFile = ./Cargo-2.0.0.lock;

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

      # Use importCargoLock instead of cargoHash/fetchCargoVendor.
      # fetchCargoVendor downloads many crates concurrently with Python requests and
      # is currently rejected by crates.io with HTTP 403 in GitHub Actions.
      cargoLock.lockFile = ./Cargo-nightly.lock;

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
