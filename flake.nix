{
  description = "My custom packages for Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      # Linux
      packages.x86_64-linux.ergo = 
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        in
          pkgs.callPackage ./ergo.nix {};

      packages.aarch64-linux.ergo = {
        ergo = 
          let
            pkgs = import nixpkgs {
              system = "aarch64-linux";
            };
          in
            pkgs.callPackage ./ergo.nix {};
      };

      # OSX
      packages.x86_64-darwin.ergo = {
        ergo = 
          let
            pkgs = import nixpkgs {
              system = "x86_64-darwin";
            };
          in
            pkgs.callPackage ./ergo.nix {};
      };


      defaultPackage.x86_64-linux = self.packages.x86_64-linux.ergo;
      defaultPackage.aarch64-linux = self.packages.aarch64-linux.ergo;
      defaultPackage.x86_64-darwin = self.packages.x86_64-darwin.ergo;
    };
}
