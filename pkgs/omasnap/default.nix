# Native Wayland screenshot and annotation overlay for Hyprland and Omarchy
pkgs: {
  omasnap = pkgs.stdenv.mkDerivation rec {
    pname = "omasnap";
    version = "1.20.1";

    src = pkgs.fetchFromGitHub {
      owner = "omacom";
      repo = "omasnap";
      rev = "d339588f3aba554f314d6233da2dddc98f83de55";
      hash = "sha256-90p1lZDj4cksAAhpbJMQwN6cMqqcZyRVESMLpjmw294=";
    };

    nativeBuildInputs = with pkgs; [
      cmake
      ninja
      pkg-config
      qt6.wrapQtAppsHook
      wayland-scanner
    ];

    buildInputs = with pkgs; [
      kdePackages.layer-shell-qt
      qt6.qtbase
      qt6.qtwayland
      wayland
      wayland-protocols
    ];

    postPatch = ''
      substituteInPlace CMakeLists.txt \
        --replace-fail /usr/share/wayland-protocols \
        ${pkgs.wayland-protocols}/share/wayland-protocols
    '';

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DBUILD_TESTING=OFF"
    ];

    meta = with pkgs.lib; {
      description = "Native Wayland screenshot and annotation overlay for Hyprland and Omarchy";
      homepage = "https://github.com/omacom/omasnap";
      license = licenses.mit;
      platforms = platforms.linux;
      maintainers = [ cristianoliveira ];
      mainProgram = "omasnap";
    };
  };
}
