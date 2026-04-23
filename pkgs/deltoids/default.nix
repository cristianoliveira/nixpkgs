# deltoids diff viewer CLI
pkgs: {
  deltoids = let
    version = "unstable-2026-04-23";
    src = pkgs.fetchFromGitHub {
      owner = "juanibiapina";
      repo = "deltoids";
      rev = "92f1775aa7e58a6f713e9b1365e70198d83632cf";
      hash = "sha256-0S4yaWQbL1A3Zii3/VIRhcunsVQYC2tdfh9deMlnsxE=";
    };
  in pkgs.rustPlatform.buildRustPackage {
    pname = "deltoids";
    inherit version src;

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.openssl ]
      ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.libiconv ];

    cargoLock = {
      lockFile = ./Cargo.lock;
    };

    buildAndTestSubdir = "crates/deltoids-cli";

    postPatch = ''
      cp ${./Cargo.lock} Cargo.lock
    '';

    meta = with pkgs.lib; {
      description = "Tools for reviewing code in the agentic era";
      homepage = "https://github.com/juanibiapina/deltoids";
      changelog = "https://github.com/juanibiapina/deltoids/commits/main";
      license = licenses.mit;
      mainProgram = "deltoids";
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };
}
