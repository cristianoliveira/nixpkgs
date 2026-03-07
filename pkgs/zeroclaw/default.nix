# ZeroClaw AI assistant CLI
pkgs: {
  zeroclaw = let
    version = "0.1.8";
    src = pkgs.fetchFromGitHub {
      owner = "zeroclaw-labs";
      repo = "zeroclaw";
      rev = "v${version}";
      hash = "sha256-6EVUk+wp3Rjhk/q2htXq41TMD+rGFO0nJbVWNbLWj5U=";
    };
  in pkgs.rustPlatform.buildRustPackage {
    pname = "zeroclaw";
    inherit version src;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    doCheck = false;

    meta = with pkgs.lib; {
      description = "ZeroClaw AI assistant runtime and CLI";
      homepage = "https://github.com/zeroclaw-labs/zeroclaw";
      changelog = "https://github.com/zeroclaw-labs/zeroclaw/releases/tag/v${version}";
      license = with licenses; [ mit asl20 ];
      mainProgram = "zeroclaw";
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };
}
