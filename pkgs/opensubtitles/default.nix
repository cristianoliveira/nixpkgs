# OpenSubtitlesDownload CLI wrapper
pkgs: {
  opensubtitles = let
    version = "6.5";
  in pkgs.stdenvNoCC.mkDerivation rec {
    pname = "opensubtitles";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "emericg";
      repo = "OpenSubtitlesDownload";
      rev = "v${version}";
      hash = "sha256-fZWwF8ybL8sRQYqSAcxjcL8lL0Jg1MbYsigdjbFaVW8=";
    };

    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/libexec/opensubtitles
      cp OpenSubtitlesDownload.py $out/libexec/opensubtitles/
      chmod +x $out/libexec/opensubtitles/OpenSubtitlesDownload.py

      makeWrapper ${pkgs.python3}/bin/python3 $out/bin/opensubtitles \
        --add-flags "$out/libexec/opensubtitles/OpenSubtitlesDownload.py" \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.procps pkgs.wget ]}
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Command-line downloader for OpenSubtitles.com subtitles";
      homepage = "https://github.com/emericg/OpenSubtitlesDownload";
      license = licenses.gpl3Plus;
      platforms = platforms.unix;
      maintainers = [ ];
      mainProgram = "opensubtitles";
    };
  };
}
