pkgs:
let
  version = "0.1.0";
  archives = {
    aarch64-darwin = {
      target = "darwin_arm64";
      hash = "sha256-7jyEtIut6Dr8O5uuYmgQL0kaW6bLX7Rnnm91Lkr7nYg=";
    };
    x86_64-darwin = {
      target = "darwin_amd64";
      hash = "sha256-sdaVMEc3Qba8QS+14M7CQ0sd5iE/O+IjjOuJK9xszLI=";
    };
    aarch64-linux = {
      target = "linux_arm64";
      hash = "sha256-riyKP0eztr8M+AK0r15/7qc81EKUw0GUc7QuG5HLg6k=";
    };
    x86_64-linux = {
      target = "linux_amd64";
      hash = "sha256-SkwPk6dfj8s2Zk0NVsWtXOlHNSiqpXbKRHDYm/0gmCw=";
    };
  };
  archive = archives.${pkgs.stdenv.hostPlatform.system};
in
{
  jeq = pkgs.stdenvNoCC.mkDerivation {
    pname = "jeq";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/cristianoliveira/jeq/releases/download/v${version}/jeq_${version}_${archive.target}.tar.gz";
      inherit (archive) hash;
    };

    nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];
    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      tar -xzf "$src" jeq
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 jeq "$out/bin/jeq"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "TypeSafe typed-judgment CLI";
      homepage = "https://github.com/cristianoliveira/jeq";
      license = licenses.mit;
      mainProgram = "jeq";
      platforms = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      maintainers = [ maintainers.cristianoliveira ];
    };
  };
}
