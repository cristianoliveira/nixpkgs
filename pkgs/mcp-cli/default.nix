# MCP CLI package
pkgs: {
  mcp-cli = let
    version = "0.3.0";

    archFile = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "mcp-cli-darwin-arm64"
      else "mcp-cli-darwin-x64"
    else if pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64 then "mcp-cli-linux-x64"
    else throw "Unsupported platform for mcp-cli";

    sha256 = if pkgs.stdenv.isDarwin then
      if pkgs.stdenv.isAarch64 then "sha256-vpkd8KEl4c+aAi/m/84jZgVSL9E4JDXOWP/fmrpmQvI="
      else "sha256-8OiQpmYmgzUAW7uhmSU/+Pbmr6520K3zT72nCLJqzC4="
    else if pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64 then "sha256-dncvKQ7aqFbL7JZ9EsM8ub9Jz/AU9Vow0EJFz4lwgXw="
    else throw "Unsupported platform for mcp-cli";

    src = pkgs.fetchurl {
      url = "https://github.com/philschmid/mcp-cli/releases/download/v${version}/${archFile}";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "mcp-cli";
    inherit version src;

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp ${src} $out/bin/mcp-cli
      chmod +x $out/bin/mcp-cli
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "A lightweight CLI for interacting with MCP servers";
      homepage = "https://github.com/philschmid/mcp-cli";
      license = licenses.mit;
      platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      maintainers = [ ];
    };
  };
}
