# Surf CLI — browser automation for AI agents
pkgs: {
  surf-cli = let
    version = "2.7.2";
    src = pkgs.fetchFromGitHub {
      owner = "nicobailon";
      repo = "surf-cli";
      rev = "v${version}";
      sha256 = "sha256-Ktyg7kfw2CV4EBbxkxtqlClp9fZq2G6CCIrAE4sWXEU=";
    };
  in pkgs.buildNpmPackage {
    pname = "surf-cli";
    inherit version src;

    npmDepsHash = "sha256-lmSqdviehbyQgHKcbl6/pgP5l/DrxqQly8ek3QO+9RA=";
    dontNpmBuild = true;

    meta = with pkgs.lib; {
      description = "CLI for AI agents to control Chrome. Zero config, agent-agnostic, battle-tested.";
      homepage = "https://github.com/nicobailon/surf-cli";
      changelog = "https://github.com/nicobailon/surf-cli/releases/tag/v${version}";
      license = licenses.mit;
      mainProgram = "surf";
      platforms = platforms.all;
    };
  };
}
