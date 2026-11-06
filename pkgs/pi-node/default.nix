{ pkgs ? import <nixpkgs> { }, ... }: {
  pi-node =
    let
      version = "1.4.0";

      # Upstream does not check in packages/ai/src/providers/data (gitignored) and
      # build:offline fails without it. The npm tarball of @earendil-works/pi-ai is
      # immutable and ships the exact dist/providers/data upstream built this
      # release with, so we copy it in instead of regenerating from live APIs.
      # Bump this hash together with version.
      modelDataTarball = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz";
        hash = "sha256-tA4rqLtvwzKQj4uW6DfcLR/ftF65zTgvWu0RFGKYHjw=";
      };
    in
    pkgs.buildNpmPackage rec {
      pname = "pi";
      inherit version;

      src = pkgs.fetchFromGitHub {
        owner = "earendil-works";
        repo = "pi";
        # Pin the commit referenced by the v1.4.0 release tag.
        rev = "4a080252f06caf63a525d7873c5d94d3c23887e0";
        hash = "sha256-N9NOpiiZTbOMDMV+CxvJAgtLjJJ1/8NJBGS0cFHkhsc=";
      };

      npmDepsHash = "sha256-aBzVz78IxZQlzPYC72Ufa2YFtkow6nZR24YBYZrv9W0=";
      npmBuildScript = "build:offline";

      nativeBuildInputs = [
        pkgs.gnutar
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
        # Restore the gitignored model data this release was built with upstream.
        # check:model-data inside build:offline verifies the manifest hashes.
        tar -xzf ${modelDataTarball} --strip-components=3 -C packages/ai/src/providers package/dist/providers/data
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
