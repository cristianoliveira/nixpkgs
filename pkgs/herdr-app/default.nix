pkgs:
let
  inherit (pkgs) lib stdenv;
  system = stdenv.hostPlatform.system;
  platforms = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ];
  appHashes = {
    aarch64-linux = "sha256-LluwXEfP+60BitNCF+pMgWR21+uEJpL3QHmMkCDwKB4=";
    x86_64-linux = "sha256-d7C+cqRsoUuzZzZaBBZGQfkUs6aXErrDkdOcVqlZvvQ=";
    aarch64-darwin = "sha256-9d0LyBqp72HPv7bvn9v0/n9mTU7Gdu4NyI8TzJdZ0NA=";
  };
  coreHashes = {
    aarch64-linux = "sha256-zzM5PPlQu3Y3NNw+FmEKudr4SSORpO8N5WAmzX91KFM=";
    x86_64-linux = "sha256-Wy+Xy0sqnXprLMWUJiggPtn7t8wMK0sJrYpvVkjiRrc=";
    aarch64-darwin = "sha256-d9ivCS4lrmUPRCTW2tJ1FPaRahHYB/sHUoWM0nwh5Pw=";
  };
  target = if stdenv.isDarwin then "macos-aarch64" else if stdenv.isAarch64 then "linux-aarch64" else "linux-x86_64";
  core = stdenv.mkDerivation rec {
    pname = "herdr-core";
    version = "0.1.18";
    src = pkgs.fetchurl {
      url = "https://releases.herdr.dev/core/${version}/herdr-core-${target}.tar.gz";
      hash = coreHashes.${system};
    };
    sourceRoot = ".";
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      ${if stdenv.isDarwin then ''
        mkdir -p "$out/Applications"
        cp -R "Herdr Core.app" "$out/Applications/"
        ln -s "$out/Applications/Herdr Core.app/Contents/MacOS/herdr-core" "$out/bin/herdr-core"
      '' else ''
        install -m755 herdr-core "$out/bin/herdr-core"
      ''}
      ln -s herdr-core "$out/bin/hc"
      runHook postInstall
    '';
  };
in
{
  herdr-app = stdenv.mkDerivation rec {
    pname = "herdr-app";
    version = "0.1.13";
    src = pkgs.fetchurl {
      url = "https://releases.herdr.dev/app/${version}/herdr-app-${target}.tar.gz";
      hash = appHashes.${system};
    };
    sourceRoot = ".";
    dontStrip = stdenv.isDarwin;
    nativeBuildInputs = [ pkgs.makeWrapper ] ++ lib.optionals stdenv.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = lib.optionals stdenv.isLinux (with pkgs; [ stdenv.cc.cc.lib fontconfig freetype libxkbcommon wayland vulkan-loader libxcb ]);
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      ${if stdenv.isDarwin then ''
        mkdir -p "$out/Applications"
        cp -R Herdr.app "$out/Applications/"
        makeWrapper "$out/Applications/Herdr.app/Contents/MacOS/Herdr" "$out/bin/herdr-app" \
          --prefix PATH : ${lib.makeBinPath [ core ]}
      '' else ''
        install -Dm755 herdr-app/herdr-app "$out/libexec/herdr-app"
        install -Dm644 herdr-app/herdr-app.svg "$out/share/icons/hicolor/scalable/apps/herdr-app.svg"
        makeWrapper "$out/libexec/herdr-app" "$out/bin/herdr-app" \
          --prefix PATH : ${lib.makeBinPath [ core ]} \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [ vulkan-loader wayland libxkbcommon ])}
        mkdir -p "$out/share/applications"
        cat > "$out/share/applications/herdr-app.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Herdr
Comment=Terminals and coding agents that keep running
Exec=$out/bin/herdr-app
Icon=herdr-app
Terminal=false
Categories=Development;
StartupWMClass=herdr-app
EOF
      ''}
      runHook postInstall
    '';
    meta = {
      description = "Desktop app for terminals and coding agents";
      homepage = "https://github.com/herdrdev/herdr-app";
      license = lib.licenses.asl20;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      inherit platforms;
      mainProgram = "herdr-app";
    };
  };
}
