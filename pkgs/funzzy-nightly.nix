{ lib , rustPlatform , fetchFromGitHub , stdenv , darwin }:
  rustPlatform.buildRustPackage rec {
    pname = "funzzy-nightly";
    version = "16774a5";

    src = fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "funzzy";
      rev = "master";
      hash = "sha256-/yfhwrvm54IlAqpub3wqygcLthhMJCpbMmtKROZ9j8o=";
    };

    cargoHash = "sha256-ugF2/LmfOhYhlV4nKqhmll5nBvp+HRevhYRTY2SO3Rc=";

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

