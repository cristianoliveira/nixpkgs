{ lib , rustPlatform , fetchFromGitHub , stdenv , darwin }:
  rustPlatform.buildRustPackage rec {
    pname = "funzzy-nightly";
    version = "master";

    src = fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "funzzy";
      rev = "master";
      hash = "sha256-65IdsRnzz4ik3TrDmAf/mp0RvpAjWckajy4fNuanenc=";
    };

    cargoHash = "sha256-g+fdO46LKvxHiynD/uCGfw3iJefm87oI+62i8BIiVhE";

    # When installing from source only run unit tests
    checkPhase = ''
      cargo test $UNIT_TEST --lib
    '';

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreServices
    ];

    meta = with lib; {
      description = "A lightweight watcher";
      homepage = "https://github.com/cristianoliveira/funzzy";
      changelog = "https://github.com/cristianoliveira/funzzy/releases/tag/${src.rev}";
      license = licenses.mit;
      maintainers = with maintainers; [ cristianoliveira ];
    };
  }

