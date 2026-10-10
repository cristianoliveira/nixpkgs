pkgs:
{
  ulauncher-sway-plus = pkgs.stdenvNoCC.mkDerivation {
    pname = "ulauncher-sway-plus";
    version = "unstable-2026-06-19";

    src = pkgs.fetchFromGitHub {
      owner = "cristianoliveira";
      repo = "ulauncher-sway-plus";
      rev = "e3c5fd080f02075347fc0fadc908815ae6eb5b45";
      hash = "sha256-rtztDFR8VHBK+JOFQREBVWkV4YKbJ7REBx6Ec9pehbk=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/ulauncher/extensions/ulauncher-sway-plus
      cp -r . $out/share/ulauncher/extensions/ulauncher-sway-plus/
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Ulauncher extension for managing Sway windows, marks, outputs, and workspaces";
      homepage = "https://github.com/cristianoliveira/ulauncher-sway-plus";
      license = licenses.lgpl3Only;
      platforms = platforms.linux;
      maintainers = [ cristianoliveira ];
    };
  };
}
