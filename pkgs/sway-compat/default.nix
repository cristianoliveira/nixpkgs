# macOS-style window cycling and focus history for Sway
pkgs: {
  sway-compat = pkgs.buildGoModule {
    pname = "sway-compat";
    version = "unstable-2026-10-08";

    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "sway-compat";
      rev = "6a6947fc78754140c494c542614104c9ffeec409";
      hash = "sha256-ZlriCDSY2+DL9H5zzBetAaHLkvscAV1SgcnPWwBpE8M=";
    };

    vendorHash = "sha256-s7gzjDfmk0YEAhfKRCTzIE4Fn/6mHaE5rXV22WzrCMk=";

    ldflags = [
      "-s"
      "-w"
      "-X github.com/cristianoliveira/sway-compat/cmd.version=unstable-2026-10-08"
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
