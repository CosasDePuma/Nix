{lib, ...}: {
  flake.modules = {
    darwin.zsh-software = {
      homebrew.brews = ["zsh"];
    };

    homeManager.zsh-software = _: {
      programs.zsh = {
        enable = lib.mkDefault true;
        enableCompletion = lib.mkDefault true;
        autosuggestion = {
          enable = lib.mkDefault true;
          strategy = lib.mkDefault ["history"];
        };
      };
    };

    nixos.zsh-software = _: {
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
