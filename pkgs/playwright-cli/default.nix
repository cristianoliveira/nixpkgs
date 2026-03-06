# Playwright CLI for browser automation
pkgs: {
  playwright-cli = let
    version = "0.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "microsoft";
      repo = "playwright-cli";
      rev = "v${version}";
      sha256 = "sha256-Ao3phIPinliFDK04u/V3ouuOfwMDVf/qBUpQPESziFQ=";
    };
  in pkgs.buildNpmPackage {
    pname = "playwright-cli";
    inherit version src;

    npmDepsHash = "sha256-4x3ozVrST6LtLoHl9KtmaOKrkYwCK84fwEREaoNaESc=";
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
