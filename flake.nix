{
  description = "Cristian Oliveira's packages";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      systemPackages = map (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          packages."${system}" = {
            ergo = pkgs.callPackage ./ergo.nix {};
            funzzy = pkgs.callPackage ./funzzy.nix {};
          };
        }
      ) systems;
    in
      # Reduce the list of packages of packages into a single attribute set
      builtins.foldl' (cur: acc: cur // acc) {} systemPackages;
}
