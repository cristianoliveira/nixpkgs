# eToro trading CLI
pkgs: {
  etoro-cli =
    let
      version = "unstable-2026-07-18";
    in
    pkgs.buildGoModule {
      pname = "etoro-cli";
      inherit version;

      src = pkgs.fetchFromGitHub {
        owner = "carbon-ni";
        repo = "etoro-cli";
        rev = "62b4d94b0e4867119f8304ea640b13a543b365d5";
        hash = "sha256-6hGZ/rvElyDSWh2pew/zutTPhl8W1QNZQtjeGrn6ums=";
      };

      vendorHash = "sha256-cWmZg5DRoM/KQI2mJqSu9YXyUN/TpfV0DbBCIj08eGg=";

      ldflags = [
        "-s"
        "-w"
        "-X github.com/marianopa-tr/etoro-cli/cmd.version=${version}"
        "-X github.com/marianopa-tr/etoro-cli/cmd.commit=62b4d94"
        "-X github.com/marianopa-tr/etoro-cli/cmd.date=2026-07-18T00:00:00Z"
      ];

      postInstall = ''
        mv $out/bin/etoro-cli $out/bin/etoro
      '';

      meta = with pkgs.lib; {
        description = "Trade, invest, and copy on eToro from the terminal";
        homepage = "https://github.com/carbon-ni/etoro-cli";
        license = licenses.mit;
        mainProgram = "etoro";
        platforms = platforms.unix;
        maintainers = [ ];
      };
    };
}
