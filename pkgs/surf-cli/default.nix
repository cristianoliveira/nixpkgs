# Surf CLI — browser automation for AI agents
pkgs: {
  surf-cli =
    let
      version = "2.19.0";
      src = pkgs.fetchFromGitHub {
        owner = "nicobailon";
        repo = "surf-cli";
        rev = "v${version}";
        sha256 = "sha256-HRLOnS3EarI1LE7uEJjaFCFsdAdnr1xJHjWQgMc46Gk=";
      };
      dist = pkgs.fetchurl {
        url = "https://registry.npmjs.org/surf-cli/-/surf-cli-${version}.tgz";
        hash = "sha256-nlabMQGms4j1sY8jWhYiCNfOpdWcWBUCwvrzrWM/EjE=";
      };
    in
    pkgs.buildNpmPackage {
      pname = "surf-cli";
      inherit version src;

      npmDepsHash = "sha256-KBaougk/KZGykT8XXDUndWq0hclN8ALC9Ukv7lxx5v0=";
      dontNpmBuild = true;

      postUnpack = ''
        tar -xzf ${dist} --strip-components=1 -C $sourceRoot package/dist
      '';

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
