# Pixel-perfect screenshot comparison CLI
pkgs: {
  pxp = let
    version = "0.1.0";
  in pkgs.buildGoModule {
    pname = "pxp";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "pxp";
      rev = "v${version}";
      hash = "sha256-KX51/r587FxJqajZt0X4jxttiVAoOaijjjoWBNGxa7Y=";
    };

    vendorHash = "sha256-4pKNmHBJn50Q1hdv/7g+ep7nxEkdCCqj2eyUkZIMB5Q=";
    subPackages = [ "cmd/pxp" ];
    proxyVendor = true;

    meta = with pkgs.lib; {
      description = "Pixel-perfect screenshot comparison CLI";
      homepage = "https://github.com/cristianoliveira/pxp";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ cristianoliveira ];
      mainProgram = "pxp";
    };
  };
}
