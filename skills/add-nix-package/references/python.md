# Python Pattern (`buildPythonApplication` / `buildPythonPackage`)

## When to use

- The project is a Python CLI, app, or library.
- Dependencies are from PyPI or source and should be propagated correctly.

## Typical helpers and fields

- Helpers: `buildPythonApplication` (CLI/app), `buildPythonPackage` (library)
- Sources: `fetchPypi`, `fetchFromGitHub`
- Common fields: `pname`, `version`, `pyproject` or `format`, `src`, `propagatedBuildInputs`, `nativeBuildInputs`, `meta.mainProgram`

## Minimal snippet

```nix
{ lib, buildPythonApplication, fetchPypi, requests }:

buildPythonApplication rec {
  pname = "my-python-cli";
  version = "1.2.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  propagatedBuildInputs = [ requests ];

  meta = with lib; {
    description = "Example Python CLI";
    license = licenses.asl20;
    mainProgram = "my-python-cli";
  };
}
```

## Real examples in `.local/nixpkgs/*`

- `.local/nixpkgs/pkgs/tools/virtualization/linode-cli/default.nix`
- `.local/nixpkgs/pkgs/tools/networking/s3cmd/default.nix`
- `.local/nixpkgs/pkgs/tools/security/cve-bin-tool/default.nix`

## Pitfalls and checks

- Choose `buildPythonApplication` vs `buildPythonPackage` based on intended output.
- Keep runtime dependencies in `propagatedBuildInputs`; build-only tools go in `nativeBuildInputs`.
- If `pyproject = true`, ensure backend tooling is present and avoid implicit network access.
