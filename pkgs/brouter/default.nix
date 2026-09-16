# Route URLs to the right browser using a version-controlled configuration
pkgs: {
  brouter = pkgs.buildGoModule rec {
    pname = "brouter";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "brouter";
      rev = "f7ab1a19368ae472fc043288b797f7f64ab4e765";
      hash = "sha256-TWHANh1VghQqI1tQ7B1KD6M6Qj+bY8wYBRx2xLQzGHk=";
    };

    # The upstream module currently declares Go 1.27, which is not yet
    # available in nixpkgs. The source does not use newer language features.
    postPatch = ''
      substituteInPlace go.mod --replace-fail 'go 1.27' 'go 1.25'
    '';

    vendorHash = "sha256-auuwDfIhmAyLv8UjVz2eBFUXrRiNmvktifPxRKsEJxY=";
    subPackages = [ "cmd/brouter" ];
    doCheck = false;

    meta = with pkgs.lib; {
      description = "Route URLs to the right browser using a version-controlled configuration";
      homepage = "https://github.com/cristianoliveira/brouter";
      license = licenses.mit;
      platforms = platforms.unix;
      maintainers = [ cristianoliveira ];
      mainProgram = "brouter";
    };
  };
}
