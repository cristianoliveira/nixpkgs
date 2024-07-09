{
  description = "flake lua";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, utils }: 
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        shell = pkgs.bash;

        pluginPkgs = with pkgs; [
          (lua5_2.withPackages (ps: with ps; [
            busted 
            luafilesystem
            luacheck 
            luarocks
          ]))
          neovim
        ];

        luapkg = pkgs.stdenv.mkDerivation {
          name = "fzz vim for ${system}";
          src = ./.;
          doCheck = true;

          checkInputs = pluginPkgs;

          # NOTE: Configure the test environment
          configurePhase = ''
            echo "configure phase"
          '';

          # NOTE: Run the tests
          checkPhase = ''
            echo "Running quick checks:"
            echo "Running tests: for ${system}"
          '';

          buildPhase = ''
            echo "Building plugins for ${system}"
          '';
        };
      in {
        devShells.default = pkgs.mkShell {
          default = luapkg;
          # Another defivation
          luapkg = luapkg;
        };

        packages = {
          default = luapkg;
          # Another defivation
          luapkg = luapkg;
        };
    });
}
