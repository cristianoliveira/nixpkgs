{ pkgs, ... }:
  let 
    _version = "master";
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
        sha256 = "sha256-q7MZ8i5ezTRj5XUYmPqNO0iCE3Iu1KNCr4SPhjYFylY=";
      };

      modSha256 = "sha256-yXWM59zoZkQPpOouJoUd5KWfpdCBw47wknb+hYy6rh0=";

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
