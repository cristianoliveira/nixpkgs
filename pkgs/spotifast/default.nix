pkgs:
let
  inherit (pkgs) lib stdenv;
  system = stdenv.hostPlatform.system;
  version = "0.17.1";
  sources = {
    aarch64-linux = {
      target = "aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-CaFdpiRIX5p7SUlJHPW7+2sXrvSKEc+GilR49Pweauk=";
    };
    x86_64-linux = {
      target = "x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-ZRcC1PGL+cM47/lhN3I8Ei4Yf9SJAq9L5WLcmwZMSXA=";
    };
    aarch64-darwin = {
      target = "macos-universal.dmg";
      hash = "sha256-h00tttPu3FVeGhuUWCJKFZz3U6utKVs2+om9Ld47Ijg=";
    };
    x86_64-darwin = sources.aarch64-darwin;
  };
  source = sources.${system};
  runtimeLibraries = with pkgs; [
    alsa-lib
    dbus
    libGL
    libx11
    libxcursor
    libxi
    libxrandr
    libxkbcommon
    wayland
    pipewire
    libpulseaudio
  ];
in
{
  spotifast = stdenv.mkDerivation {
    pname = "spotifast";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/crmne/spotifast/releases/download/v${version}/spotifast-v${version}-${source.target}";
      inherit (source) hash;
    };

    nativeBuildInputs = [ pkgs.makeWrapper ]
      ++ lib.optionals stdenv.isDarwin [ pkgs._7zz ]
      ++ lib.optionals stdenv.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = lib.optionals stdenv.isLinux (runtimeLibraries ++ [ stdenv.cc.cc.lib ]);

    sourceRoot = if stdenv.isDarwin then "." else "spotifast-v${version}-${lib.removeSuffix ".tar.gz" source.target}";
    dontStrip = stdenv.isDarwin;

    # The release DMG uses APFS, which undmg cannot extract.
    unpackPhase = lib.optionalString stdenv.isDarwin ''
      runHook preUnpack
      7zz x "$src" -oapp
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
    '' + lib.optionalString stdenv.isDarwin ''
      mkdir -p "$out/Applications"
      cp -R app/Spotifast.app "$out/Applications/"
      chmod +x "$out/Applications/Spotifast.app/Contents/MacOS/Spotifast"
      makeWrapper "$out/Applications/Spotifast.app/Contents/MacOS/Spotifast" "$out/bin/spotifast"
    '' + lib.optionalString stdenv.isLinux ''
      install -Dm755 spotifast "$out/bin/spotifast"
      install -Dm644 packaging/applications/spotifast.desktop "$out/share/applications/spotifast.desktop"
      install -Dm644 packaging/icons/spotifast.svg "$out/share/icons/hicolor/scalable/apps/spotifast.svg"
      wrapProgram "$out/bin/spotifast" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries} \
        --prefix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]}
    '' + ''
      runHook postInstall
    '';

    meta = {
      description = "Fast native Spotify client with local playback and Spotify Connect";
      homepage = "https://github.com/crmne/spotifast";
      changelog = "https://github.com/crmne/spotifast/releases/tag/v${version}";
      license = lib.licenses.mit;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = builtins.attrNames sources;
      mainProgram = "spotifast";
    };
  };
}
