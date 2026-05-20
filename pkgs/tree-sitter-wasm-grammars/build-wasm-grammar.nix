{ stdenv
, tree-sitter
, emscripten
, jq
, lib
,
}:

{ language
, version
, src
, meta ? { }
, generate ? false
, excludeBrokenTreeSitterJson ? false
, ...
}@args:

stdenv.mkDerivation (
  {
    pname = "tree-sitter-${language}-wasm";

    inherit version src;

    nativeBuildInputs = [
      tree-sitter
      emscripten
      jq
    ];

    postPatch = lib.optionalString excludeBrokenTreeSitterJson ''
      rm tree-sitter.json
    '';

    configurePhase = ''
      runHook preConfigure
      if [[ -e tree-sitter.json ]]; then
        NIX_VERSION=${lib.head (lib.splitString "+" version)}
        SRC_VERSION=$(jq -r '.metadata.version' tree-sitter.json)
        if [[ "$NIX_VERSION" != "$SRC_VERSION" ]]; then
          nixErrorLog "grammar version ($NIX_VERSION) differs from source ($SRC_VERSION)"
        fi

        GRAMMAR=$(jq -c 'first(.grammars[] | select(.name == env.language))' tree-sitter.json)
        if [[ -z "$GRAMMAR" || "$GRAMMAR" == "null" ]]; then
          GRAMMAR=$(jq -c 'first(.grammars[]) // {}' tree-sitter.json)
          NAME=$(jq -r '.name' <<< "$GRAMMAR")
          SRC_LANGS=$(jq -r '[.grammars[].name] | join(", ")' tree-sitter.json)
          nixErrorLog "grammar name ($language) not found in source grammars ($SRC_LANGS), continuing with $NAME"
        fi

        cd -- "$(jq -r '.path // "."' <<< "$GRAMMAR")"
      else
        nixWarnLog "grammar source is missing tree-sitter.json"
      fi
      runHook postConfigure
    '';

    preBuild = lib.optionalString generate ''
      tree-sitter generate
    '';

    buildPhase = ''
      runHook preBuild
      export EM_CACHE=$(mktemp -d)
      export HOME=$(mktemp -d)
      mkdir -p "$EM_CACHE"

      # Some Emscripten versions copy read-only files from the Nix store into
      # EM_CACHE, then try to update the same cache during the real grammar
      # build. Pre-warm the cache and make it writable before invoking the
      # tree-sitter CLI.
      echo 'int main() { return 0; }' > emcache-warmup.c
      emcc emcache-warmup.c -o emcache-warmup.js || true
      chmod -R u+rwX "$EM_CACHE"

      tree-sitter build --wasm -o ${language}.wasm
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir $out
      mv ${language}.wasm $out/
      runHook postInstall
    '';

    meta = {
      description = "Tree-sitter WASM grammar for ${language}";
    }
    // (lib.optionalAttrs (src ? meta.homepage) {
      homepage = src.meta.homepage;
    })
    // meta;
  }
  // (lib.optionalAttrs (args ? location && args.location != null) {
    setSourceRoot = "sourceRoot=$(echo */${args.location})";
  })
    // removeAttrs args [
    "generate"
    "excludeBrokenTreeSitterJson"
    "meta"
    "requires"
  ]
)
