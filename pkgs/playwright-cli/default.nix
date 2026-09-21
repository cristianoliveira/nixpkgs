# Playwright CLI for browser automation
pkgs: {
  playwright-cli =
    let
      version = "0.1.21";
      src = pkgs.fetchFromGitHub {
        owner = "microsoft";
        repo = "playwright-cli";
        rev = "v${version}";
        sha256 = "sha256-ZHfQBZQejJKNYfhszd99i4GIzEpomBzX0/HkMK2T8DQ=";
      };
    in
    pkgs.buildNpmPackage {
      pname = "playwright-cli";
      inherit version src;

      npmDepsHash = "sha256-aTn5CFeAzoH4J+TYiM4HOULzWAeyU3xmD4wkQdsJrGY=";
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
