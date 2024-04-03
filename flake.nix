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
          packages."${system}" = import ./default.nix { inherit pkgs; };
        }
      ) systems;

      mergeAttrs = attrs: builtins.foldl' (a: b: a // b) {} attrs;
    in
      # Reduce the list of packages into a single attribute set
      mergeAttrs systemPackages;
}
