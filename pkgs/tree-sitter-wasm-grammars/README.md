# Tree-sitter WASM grammars

This package adds a WASM grammar builder to `tree-sitter` through this flake overlay.

It exposes:

- `pkgs.tree-sitter.passthru.buildWasmGrammar`
- `pkgs.tree-sitter.passthru.builtWasmGrammars`

The grammar sources come from upstream nixpkgs `nvim-treesitter/generated.nix`; builds are lazy, so only selected grammars are built.

## Use in a dev shell

```nix
{
  inputs.conixpkgs.url = "github:cristianoliveira/nixpkgs";

  outputs = { nixpkgs, conixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = conixpkgs.lib.withOverlays system [];
    grammars = pkgs.tree-sitter.passthru.builtWasmGrammars;
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        pkgs.nodejs
        grammars.python
        grammars.json
      ];

      shellHook = ''
        export TREE_SITTER_PYTHON_WASM=${grammars.python}/python.wasm
        export TREE_SITTER_JSON_WASM=${grammars.json}/json.wasm
      '';
    };
  };
}
```

## Use with `web-tree-sitter`

Install the JavaScript runtime:

```sh
npm install web-tree-sitter
```

Load a grammar from the Nix store path exposed by the dev shell:

```js
import Parser from "web-tree-sitter";

await Parser.init();

const parser = new Parser();
const Python = await Parser.Language.load(process.env.TREE_SITTER_PYTHON_WASM);

parser.setLanguage(Python);

const tree = parser.parse("print('hello')");
console.log(tree.rootNode.toString());
```

## Copy grammars into app assets

For browser apps, copy selected `.wasm` files into an assets directory:

```nix
let
  grammars = pkgs.tree-sitter.passthru.builtWasmGrammars;
in
pkgs.runCommand "tree-sitter-wasm-assets" { } ''
  mkdir -p $out
  cp ${grammars.python}/python.wasm $out/
  cp ${grammars.json}/json.wasm $out/
''
```

Then load from your public assets path:

```js
const Python = await Parser.Language.load("/assets/python.wasm");
```

## Build and use without installing

Build one grammar from this flake without adding it to a profile or system config:

```sh
nix build --impure --expr '
let
  f = builtins.getFlake "github:cristianoliveira/nixpkgs";
  pkgs = f.lib.withOverlays builtins.currentSystem [];
in
  pkgs.tree-sitter.passthru.builtWasmGrammars.python
'
```

The result symlink contains the `.wasm` file:

```sh
ls ./result
# python.wasm
```

Use it directly from JavaScript:

```js
const Python = await Parser.Language.load("./result/python.wasm");
```

Build multiple grammars into one result folder:

```sh
nix build --impure --expr '
let
  f = builtins.getFlake "github:cristianoliveira/nixpkgs";
  pkgs = f.lib.withOverlays builtins.currentSystem [];
  grammars = pkgs.tree-sitter.passthru.builtWasmGrammars;
in
  pkgs.runCommand "tree-sitter-wasm-grammars" { } '\''
    mkdir -p $out
    cp ${grammars.javascript}/javascript.wasm $out/
    cp ${grammars.python}/python.wasm $out/
    cp ${grammars.go}/go.wasm $out/
    cp ${grammars.rust}/rust.wasm $out/
  '\''
'
```

Then:

```sh
ls ./result
# go.wasm javascript.wasm python.wasm rust.wasm
```

Or use a grammar via this flake overlay in Nix code:

```nix
pkgs.tree-sitter.passthru.builtWasmGrammars.python
```
