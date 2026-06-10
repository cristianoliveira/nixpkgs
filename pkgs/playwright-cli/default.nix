# Playwright CLI for browser automation
pkgs: {
  playwright-cli =
    let
      version = "0.1.14";
      src = pkgs.fetchFromGitHub {
        owner = "microsoft";
        repo = "playwright-cli";
        rev = "v${version}";
        sha256 = "sha256-wLE04sfPMh43IzIp6/HKBjloy3iSSanSYdYtklc6lQ4=";
      };
    in
    pkgs.buildNpmPackage {
      pname = "playwright-cli";
      inherit version src;

      npmDepsHash = "sha256-0bvwryiyPskay+h8+0RiOmnamHkmcRRK00q7ZEPdj1g=";
      dontNpmBuild = true;

      passthru = {
        # Newer upstream tags intentionally print a deprecation message and exit.
        skipBulkUpdate = true;
      };

      meta = with pkgs.lib; {
        description = "Playwright CLI for browser automation";
        homepage = "https://github.com/microsoft/playwright-cli";
        changelog = "https://github.com/microsoft/playwright-cli/releases/tag/v${version}";
        license = licenses.asl20;
        maintainers = with maintainers; [ imalison ];
        mainProgram = "playwright-cli";
      };
    };
}
