{ lib , rustPlatform , fetchFromGitHub , stdenv , darwin }:
  rustPlatform.buildRustPackage rec {
    pname = "funzzy-nightly";
    version = "master";

    src = fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "funzzy";
      rev = "master";
      hash = "sha256-ZwQwGaFxhJT4ftJ4PLQ+qj4h5/6OnftT43KeJg48YCo=";
    };

    cargoHash = "sha256-mT7uyCy/UU/azKUUcl/0X9qnK/8JWeLduhAb5cdyI48=";

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

