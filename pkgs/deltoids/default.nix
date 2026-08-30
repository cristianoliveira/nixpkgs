# deltoids - tools for reviewing code in the agentic era
# https://github.com/juanibiapina/deltoids
#
# Uses the per-platform prebuilt binaries published with each GitHub release.
pkgs: {
  deltoids = let
    version = "0.12.1";

    archTriple =
      if pkgs.stdenv.isDarwin then
        if pkgs.stdenv.isAarch64 then "aarch64-apple-darwin"
        else "x86_64-apple-darwin"
      else if pkgs.stdenv.isAarch64 then "aarch64-unknown-linux-gnu"
      else if pkgs.stdenv.isx86_64 then "x86_64-unknown-linux-gnu"
      else throw "Unsupported platform for deltoids";

    sha256 =
      if pkgs.stdenv.isDarwin then
        if pkgs.stdenv.isAarch64 then "sha256-5rpsDOvMKjJFKyUD6U9lPJkvZSCkQFLgBblyjhTOykk="
        else "sha256-EtTFAFZPW6AMywng/l7llw52//miQ8vd70mvXR0/MKo="
      else if pkgs.stdenv.isAarch64 then "sha256-8owXjHYj4JCzCh/8JOaop35vjLSNZWpyDRPZvPUhkdw="
      else "sha256-IDAlxn5unvbOL3a4MZXcX6emevkZRAigogIQyjDY+1k=";

    src = pkgs.fetchurl {
      url = "https://github.com/juanibiapina/deltoids/releases/download/v${version}/deltoids-cli-${archTriple}.tar.gz";
      inherit sha256;
    };
  in pkgs.stdenv.mkDerivation {
    pname = "deltoids";
    inherit version src;

    dontConfigure = true;
    dontBuild = true;

    # Prebuilt glibc-linked binary needs interpreter/rpath patching on Linux.
    nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.stdenv.cc.cc.lib pkgs.zlib ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp deltoids $out/bin/deltoids
      chmod +x $out/bin/deltoids
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Tools for reviewing code in the agentic era";
      homepage = "https://github.com/juanibiapina/deltoids";
      changelog = "https://github.com/juanibiapina/deltoids/releases/tag/v${version}";
      license = licenses.mit;
      mainProgram = "deltoids";
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      maintainers = [ ];
    };
  };
}
