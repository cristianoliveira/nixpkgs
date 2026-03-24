# ZeroClaw AI assistant CLI
pkgs: {
  zeroclaw = let
    version = "0.6.0";
    src = pkgs.fetchFromGitHub {
      owner = "zeroclaw-labs";
      repo = "zeroclaw";
      rev = "v${version}";
      hash = "sha256-MOjCt+TqgPbJK6XVCVnMpFv4+qdVPArsuYpWEEBPt6Q=";
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
