{ pkgs, lib, fetchFromGitHub, ...  }: 
  pkgs.buildNpmPackage rec {

    name = "snipgpt";
    version = "0.2.1";

    dontNpmBuild = true;

    buildInputs = with pkgs; [
      nodejs_20
    ];

    src = fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "snipgpt";
      rev = "v${version}";
      sha256 = "sha256-3ViFO0drJ6PrEQZECKUIQiMCAEsq12ViTxV7jgPLhMo=";
    };

    npmDepsHash = "sha256-aYJLbGQeH9EthA3zq/olvP0xNZVzvwXtt0Tz7dMQS6U=";

    npmFlags = ["--ignore-scripts"];

    installPhase = ''
      mkdir -p $out
      cp -r $src/bin $out/bin
    '';

    meta = with lib; {
      description = "Ask snipets in your terminal";
      homepage = "https://github.com/cristianoliveira/snipgpt";
      changelog = "https://github.com/cristianoliveira/snipgpt/releases/tag/${src.rev}";
      license = licenses.mit;
      maintainers = with maintainers; [ cristianoliveira ];
    };
  }

