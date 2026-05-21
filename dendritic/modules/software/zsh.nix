{lib, ...}: {
  flake.modules = {
    darwin.software-zsh = {
      homebrew.brews = ["zsh"];
    };

    homeManager.software-zsh = _: {
      programs.zsh = {
        enable = lib.mkDefault true;
        enableCompletion = lib.mkDefault true;
        autosuggestion = {
          enable = lib.mkDefault true;
          strategy = lib.mkDefault ["history"];
        };
      };
    };

    nixos.software-zsh = _: {
      programs.zsh = {
        enable = lib.mkDefault true;
        enableCompletion = lib.mkDefault true;
        autosuggestion = {
          enable = lib.mkDefault true;
          strategy = lib.mkDefault ["history"];
        };
      };
    };
  };
}
