{
  description = "Cristian Oliveira's packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";

    sway-setter.url = "github:cristianoliveira/sway-setter";
    funzzy.url = "github:cristianoliveira/funzzy";
    ergo.url = "github:cristianoliveira/ergo";

    # https://github.com/juanibiapina/mcpli
    mcpli.url = "github:juanibiapina/mcpli";
    mcplifork.url = "github:cristianoliveira/mcpli";

    aerospace-scratchpad.url = "github:cristianoliveira/aerospace-scratchpad";
    aerospace-marks.url = "github:cristianoliveira/aerospace-marks";
  };

  outputs =
    { nixpkgs
    , utils
    , sway-setter
    , funzzy
    , ergo
    , aerospace-scratchpad
    , aerospace-marks
    , mcpli
    , mcplifork
    , self
    , ...
    }:
    let
      mkExternalPackages = pkgs: system:
        let
          swaysetterPkgs = import sway-setter { inherit pkgs; };
          # Use local derivation for funzzy to avoid upstream nixpkgs compatibility churn.
          funzzyPkg = (import (self + /pkgs/funzzy) pkgs).funzzy;
          ergoPkgs = import ergo { inherit pkgs; };
          aerospaceScratchpad = import aerospace-scratchpad { inherit pkgs; };
          aerospaceMarks = import aerospace-marks { inherit pkgs; };
        in
        {
          sway-setter = swaysetterPkgs.default;
          funzzy = funzzyPkg;
          fzz = funzzyPkg;
          ergoProxy = ergoPkgs.default;
          aerospace-scratchpad = aerospaceScratchpad.default;
          aerospace-marks = aerospaceMarks.default;
          mcpli = mcpli.packages.${system}.default;
          mcpliFork = mcplifork.packages.${system}.default;
        };
      overlay = final: prev: {
        co = mkExternalPackages prev prev.system // import (self + /pkgs) prev;
      };
      perSystem = utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          externalPackages = mkExternalPackages pkgs system;

          # Import local packages from centralized pkgs/default.nix
          localPackages = import (self + /pkgs) pkgs;

          # Development shell with useful tools
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Nix-related tools
              nixpkgs-fmt
              nix-prefetch-scripts
              nix-prefetch-github

              # GitHub Actions workflow validation
              yamllint

              # GitHub CLI
              gh

              # JSON tools
              jq

              # Common utilities
              bash
              curl
              git
            ];

            shellHook = ''
              echo "🚀 Welcome to Nixpkgs development environment"
              echo ""
              echo "Available tools:"
              echo "  - nixpkgs-fmt: Format Nix files"
              echo "  - yamllint: Validate YAML files"
              echo "  - jq: Process JSON data"
              echo "  - gh: GitHub CLI"
              echo ""
              echo "Common commands:"
              echo "  - nix flake check: Check flake validity"
              echo "  - nix build .#<package>: Build a package"
              echo "  - ./scripts/check-package-updates.sh: Check for package updates"
              echo "  - yamllint .github/workflows/*.yml: Validate workflows"
              echo ""
            '';
          };
        in
        {
          packages = externalPackages // localPackages;
          devShells.default = devShell;
        });
    in
    perSystem // {
      overlays = { default = overlay; };
      lib = {
        withOverlays = system: overlays: import nixpkgs {
          inherit system;
          overlays = [ overlay ] ++ overlays;
        };
      };
    };
}
