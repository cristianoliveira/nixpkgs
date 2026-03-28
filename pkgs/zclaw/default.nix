# ZeroClaw AI assistant CLI
pkgs: {
  zclaw = let
    version = "0.6.5";
    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "zclaw";
      rev = "a5bcc98778b53b31a6eabd6f937a879ffa9bbb80";
      hash = "sha256-iRGj5J8Xo/49Q1a5qF5OO+qoDDlCSsgHS0NB23M/xtQ=";
    };
  in pkgs.rustPlatform.buildRustPackage {
    pname = "zclaw";
    inherit version src;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    doCheck = false;

    meta = with pkgs.lib; {
      description = "ZeroClaw AI assistant runtime and CLI";
      homepage = "https://github.com/cristianoliveira/zclaw";
      changelog = "https://github.com/cristianoliveira/zclaw/commits/master";
      license = with licenses; [ mit asl20 ];
      mainProgram = "zeroclaw";
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };
}
