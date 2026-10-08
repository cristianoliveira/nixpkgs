# macOS-style window cycling and focus history for Sway
pkgs: {
  sway-compat = pkgs.buildGoModule rec {
    pname = "sway-compat";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "sway-compat";
      rev = "v${version}";
      hash = "sha256-ZlriCDSY2+DL9H5zzBetAaHLkvscAV1SgcnPWwBpE8M=";
    };

    vendorHash = "sha256-s7gzjDfmk0YEAhfKRCTzIE4Fn/6mHaE5rXV22WzrCMk=";

    ldflags = [
      "-s"
      "-w"
      "-X github.com/cristianoliveira/sway-compat/cmd.version=${version}"
    ];

    meta = with pkgs.lib; {
      description = "macOS-style window cycling and focus history for Sway";
      homepage = "https://github.com/cristianoliveira/sway-compat";
      license = licenses.mit;
      mainProgram = "sway-compat";
      platforms = platforms.linux;
      maintainers = [ cristianoliveira ];
    };
  };
}
