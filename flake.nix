{
  description = "Cristian Oliveira's packages";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      recursiveMergeAttrs = listOfAttrsets: lib.fold (attrset: acc: lib.recursiveUpdate attrset acc) {} listOfAttrsets;
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      systemPackages = map (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          packages."${system}" = import ./pkgs/default.nix { inherit pkgs; };
        }
      ) systems;
    in
      # Reduce the list of packages of packages into a single attribute set
      recursiveMergeAttrs(systemPackages);
}
