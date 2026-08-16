{ pkgs ? import <nixpkgs> { }, ... }: {
  pi-node =
    let
      version = "0.84.2";

      # Upstream no longer ships checked-in model data (packages/ai/src/providers/data
      # is gitignored). The build hydrates it from four public APIs, so we pin their
      # responses via fixed-output derivations and patch generate-models.ts to read
      # them from PI_PINNED_MODEL_DATA_DIR instead of the network.
      modelsDevApi = pkgs.fetchurl {
        url = "https://models.dev/api.json";
        hash = "sha256-uCj4RT6egkDir4mTqPc4GMzx9pG3GF2xuLDS1+GQw+o=";
      };
      openrouterModels = pkgs.fetchurl {
        url = "https://openrouter.ai/api/v1/models";
        hash = "sha256-G1MbRwXC43ab0qB+OhEo5H0+sErYBYUOK+jOs1Qbf8I=";
      };
      aiGatewayModels = pkgs.fetchurl {
        url = "https://ai-gateway.vercel.sh/v1/models";
        hash = "sha256-E1k4tX1PnMRk4OWrdbQfIc4lUdklJOnolQJACWIMm4Y=";
      };
      nvidiaNimModels = pkgs.fetchurl {
        url = "https://integrate.api.nvidia.com/v1/models";
        hash = "sha256-StvuIXsr0csNl4RgAaRZqEXs3lqUX1OR92npA5ITlxQ=";
      };

      # File names match generate-models.ts: url.replace(/[^a-zA-Z0-9]+/g, "_") + ".json"
      pinnedModelData = pkgs.runCommand "pi-pinned-model-data" { } ''
        mkdir -p $out
        ln -s ${modelsDevApi} $out/https_models_dev_api_json.json
        ln -s ${openrouterModels} $out/https_openrouter_ai_api_v1_models.json
        ln -s ${aiGatewayModels} $out/https_ai_gateway_vercel_sh_v1_models.json
        ln -s ${nvidiaNimModels} $out/https_integrate_api_nvidia_com_v1_models.json
      '';

      # Plain JS on purpose: node type-strips this file, no template literals so the
      # nix string needs no escaping.
      pinnedFetchHelper = pkgs.writeText "pinned-fetch-helper.ts" ''
        function pinnedFetch(url) {
        	const dir = process.env.PI_PINNED_MODEL_DATA_DIR;
        	if (dir) {
        		const key = url.replace(/[^a-zA-Z0-9]+/g, "_");
        		const content = readFileSync(dir + "/" + key + ".json", "utf8");
        		return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(JSON.parse(content)) });
        	}
        	return fetch(url);
        }

      '';
    in
    pkgs.buildNpmPackage rec {
      pname = "pi";
      inherit version;

      src = pkgs.fetchFromGitHub {
        owner = "earendil-works";
        repo = "pi";
        rev = "v${version}";
        hash = "sha256-d29ft9otYxdHRWYIAX8KMHPpppToX9ME5LbPb1rPcYo=";
      };

      npmDepsHash = "sha256-6J5Efe+6ptCuR3VZojwYPZO8BBnnZsOQ4OAeB64uYOY=";
      # Network-free build: model data is hydrated from PI_PINNED_MODEL_DATA_DIR in preBuild.
      npmBuildScript = "build:offline";

      postPatch = ''
        # Insert helper after the shebang line; node strips types and needs line 1 intact.
        sed -i -e "1r ${pinnedFetchHelper}" packages/ai/scripts/generate-models.ts
        substituteInPlace packages/ai/scripts/generate-models.ts \
          --replace-fail 'await fetch(`''${NVIDIA_BASE_URL}/models`)' 'await pinnedFetch(`''${NVIDIA_BASE_URL}/models`)' \
          --replace-fail 'await fetch("https://openrouter.ai/api/v1/models")' 'await pinnedFetch("https://openrouter.ai/api/v1/models")' \
          --replace-fail 'await fetch(`''${AI_GATEWAY_MODELS_URL}/models`)' 'await pinnedFetch(`''${AI_GATEWAY_MODELS_URL}/models`)' \
          --replace-fail 'await fetch("https://models.dev/api.json")' 'await pinnedFetch("https://models.dev/api.json")'
      '';

      preBuild = ''
        export PI_PINNED_MODEL_DATA_DIR=${pinnedModelData}
        npm run hydrate:model-data
      '';

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
