# Playwright CLI for browser automation
pkgs: {
  playwright-cli =
    let
      version = "0.1.12";
      src = pkgs.fetchFromGitHub {
        owner = "microsoft";
        repo = "playwright-cli";
        rev = "v${version}";
        sha256 = "sha256-g7MRcSLK4ykt/fGtovoRDeHVnzMfn6/T4DYXhI+qy8s=";
      };
    in
    pkgs.buildNpmPackage {
      pname = "playwright-cli";
      inherit version src;

      npmDepsHash = "sha256-oFoojfJNWI7Ku4kY56An0lK3QkDUeEnn74bR1A6Uuhw=";
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
