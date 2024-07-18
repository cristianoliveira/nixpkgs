{
  description = "Flake with npx clis";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, utils }: 
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nodejs
            pkgs.go
            # Linter tools
            (pkgs.writeScriptBin "spectral" ''#!${pkgs.stdenv.shell}
             npx @stoplight/spectral-cli@v6.6.0 $@
             '')
            pkgs.golangci-lint
          ];
        };
    });
}
