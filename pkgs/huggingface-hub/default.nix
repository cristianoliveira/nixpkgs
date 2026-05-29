# Hugging Face Hub CLI
pkgs: {
  huggingface-hub = pkgs.symlinkJoin {
    name = "huggingface-hub-${pkgs.python3Packages.huggingface-hub.version}";
    paths = [ pkgs.python3Packages.huggingface-hub ];

    meta = with pkgs.lib; {
      description = "Official Python client and CLI for the Hugging Face Hub";
      homepage = "https://github.com/huggingface/huggingface_hub";
      license = licenses.asl20;
      platforms = platforms.unix;
      maintainers = [ ];
      mainProgram = "hf";
    };
  };
}
