{ pkgs ? import <nixpkgs> { }, ... }: {
  pi-node =
    let
      version = "0.79.4";
    in
    pkgs.buildNpmPackage rec {
      pname = "pi-node";
      inherit version;

      src = pkgs.fetchFromGitHub {
        owner = "earendil-works";
        repo = "pi";
        rev = "v${version}";
        hash = "sha256-cAlQfKtT8kLoAHYvXusbpM2I9FrRijWzSPQDSy/Kkro=";
      };

      npmDepsHash = "sha256-y3wwz0orFrUPu4XRJnHRkO9x9s+GMtBP/2g7kN336vQ=";
      npmBuildScript = "build";

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

      postPatch = ''
        # The model generators fetch live provider catalogs, which is not
        # allowed in Nix builds and can produce incomplete generated files
        # offline. Use the generated catalogs checked into the release tag.
        substituteInPlace packages/ai/package.json \
          --replace-fail '"build": "npm run generate-models && npm run generate-image-models && tsgo -p tsconfig.build.json"' \
                         '"build": "tsgo -p tsconfig.build.json"'
      '';

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
