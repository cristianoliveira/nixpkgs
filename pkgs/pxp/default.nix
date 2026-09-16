# Pixel-perfect screenshot comparison CLI
pkgs: {
  pxp = let
    version = "0.2.0";
  in pkgs.buildGoModule {
    pname = "pxp";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "pxp";
      rev = "v${version}";
      hash = "sha256-+JaZc/v39ASQLL5hbRcHdT2yrwiuBTHPpHpeS+dTTUY=";
    };

    vendorHash = "sha256-4pKNmHBJn50Q1hdv/7g+ep7nxEkdCCqj2eyUkZIMB5Q=";
    ldflags = [ "-X main.version=${version}" ];
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
