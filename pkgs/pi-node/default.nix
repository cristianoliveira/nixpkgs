{ pkgs ? import <nixpkgs> { }, ... }: {
  pi-node =
    let
      version = "0.82.0";
    in
    pkgs.buildNpmPackage rec {
      pname = "pi";
      inherit version;

      src = pkgs.fetchFromGitHub {
        owner = "earendil-works";
        repo = "pi";
        rev = "v${version}";
        hash = "sha256-oKm0nyGmRY6rlQGMODB8DteMTVUUMroy/YXPphoxrvY=";
      };

      npmDepsHash = "sha256-3oqrN/uguYfkUHlfmKGxnLIvUo484IMGlydz6p9o/Dw=";
      # Upstream ships a network-free build that uses checked-in model data.
      npmBuildScript = "build:offline";

      nativeBuildInputs = [
        pkgs.makeWrapper
        pkgs.node-gyp
        pkgs.pkg-config
        pkgs.python3
      ];

      buildInputs = [
        pkgs.cairo
        pkgs.giflib
        pkgs.libjpeg
        pkgs.libpng
        pkgs.librsvg
        pkgs.pango
        pkgs.pixman
      ];

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/pi $out/bin
        cp -r packages node_modules package.json README.md LICENSE $out/lib/pi/
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/pi \
          --add-flags $out/lib/pi/packages/coding-agent/dist/cli.js \
          --set PI_PACKAGE_DIR $out/lib/pi/packages/coding-agent
        ln -s $out/bin/pi $out/bin/pi-node
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Pi AI coding assistant built from source and run with Node";
        homepage = "https://github.com/earendil-works/pi";
        license = licenses.mit;
        platforms = platforms.linux;
        maintainers = [ ];
        mainProgram = "pi";
      };
    };
}
