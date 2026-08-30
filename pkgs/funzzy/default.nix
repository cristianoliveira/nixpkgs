# A lightweight file watcher
pkgs: {
  funzzy =
    let
      version = "2.0.0";

      archFile =
        if pkgs.stdenv.isDarwin then
          if pkgs.stdenv.isAarch64 then "aarch64-darwin" else "x86_64-darwin"
        else if pkgs.stdenv.isAarch64 then "aarch64-linux" else "x86_64-linux";

      sha256 = {
        "aarch64-darwin" = "sha256-owS+WZCzkRKBlhGnQRwIzr+c+UpCBiMjE/HUEavtNtE=";
        "aarch64-linux" = "sha256-CyGL8FjvfFVYMs2p0cwe6EOaL4ACBqJZvEfuPl1ZXVM=";
        "x86_64-darwin" = "sha256-fXQi50aQGREeLjzxtubXE4lTIAGckUbLCby1nf7Bl0w=";
        "x86_64-linux" = "sha256-fXrfZp2PXjTVFbYnOEdrwtVdeELrCsYlLeZLmbFhCdg=";
      }.${archFile};
    in
    pkgs.stdenv.mkDerivation {
      pname = "funzzy";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/cristianoliveira/funzzy/releases/download/v${version}/funzzy-v${version}-${archFile}.tar.gz";
        inherit sha256;
      };

      nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];

      sourceRoot = ".";
      unpackPhase = ''
        runHook preUnpack
        tar xzf $src
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        install -m755 pkg/funzzy $out/bin/funzzy
        install -m755 pkg/fzz $out/bin/fzz
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "A lightweight watcher";
        homepage = "https://github.com/cristianoliveira/funzzy";
        changelog = "https://github.com/cristianoliveira/funzzy/releases/tag/v${version}";
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
      cargoLock = {
        # crates.io currently returns HTTP 403 from GitHub Actions runners.
        lockFileContents = builtins.replaceStrings
          [ "registry+https://github.com/rust-lang/crates.io-index" ]
          [ "registry+https://static.crates.io/index" ]
          (builtins.readFile ./Cargo-nightly.lock);
        extraRegistries."https://static.crates.io/index" = "https://static.crates.io/crates";
      };

      postPatch = ''
        substituteInPlace Cargo.lock \
          --replace-fail 'registry+https://github.com/rust-lang/crates.io-index' \
          'registry+https://static.crates.io/index'
      '';

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
