# SonarQube CLI
pkgs: {
  sonarqube-cli =
    let
      version = "0.13.0.1692";
      src = pkgs.fetchFromGitHub {
        owner = "SonarSource";
        repo = "sonarqube-cli";
        rev = version;
        sha256 = "sha256-5eDLcqnhRXKHTImur7wMneT5fSDiy4hF5UcejUxeh5A=";
      };
    in
    pkgs.buildNpmPackage {
      pname = "sonarqube-cli";
      inherit version src;

      npmDepsHash = "sha256-SlqMPCaX+Wmd6OxYbsleOSTmVby5sUFrWPdQyO2qlZ4=";

      postPatch = ''
        cp ${./package-lock.json} package-lock.json
      '';

      nativeBuildInputs = [ pkgs.bun ];

      npmBuildScript = "build:binary";

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp dist/sonarqube-cli $out/bin/sonar
        chmod +x $out/bin/sonar
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Command-line interface for SonarQube with AI agent integration";
        homepage = "https://github.com/SonarSource/sonarqube-cli";
        license = licenses.lgpl3Plus;
        platforms = platforms.unix;
        maintainers = [ ];
        mainProgram = "sonar";
      };
    };
}
