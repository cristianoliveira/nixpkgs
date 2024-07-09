 # allow our nixpkgs import to be overridden if desired
{ pkgs, ... }:

let 
  _version = "v0.4.1";
in
  pkgs.buildGoModule rec {
    # name of our derivation
    name = "ergo-proxy";
    version = "${_version}";

    # sources that will be used for our derivation.
    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "ergo";
      rev = _version;
      sha256 = "sha256-/VhHuJsQrxewmfP/V25r5rZady0snfYNOGyIrv3vpGA=";
    };

    modSha256 = "sha256-TkAv4064b2LNbVx6u04fNdL9WH8ycOHchOcMLbbCgVo=";

    vendorHash = "sha256-yXWM59zoZkQPpOouJoUd5KWfpdCBw47wknb+hYy6rh0=";

    ldflags = [
      "-s" "-w"
      "-X main.VERSION=${_version}"
    ];

    meta = with pkgs.lib; {
      description = "Ergo: The reverse proxy agent for local domain management";
      homepage = "https://github.com/cristianoliveira/ergo";
      license = licenses.mit;
      maintainers = with maintainers; [ cristianoliveira ];
    };
  }
