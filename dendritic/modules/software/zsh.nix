{lib, ...}: {
  flake = {
    darwinModules.software-zsh = {
      homebrew.brews = ["zsh"];
    };

    homeManagerModules.software-zsh = {
      programs.zsh = {
        enable = lib.mkDefault true;
        enableCompletion = lib.mkDefault true;
        autosuggestion = {
          enable = lib.mkDefault true;
          strategy = lib.mkDefault ["history"];
        };
      };
    };

    nixosModules.software-zsh = {
      programs.zsh = {
        enable = lib.mkDefault true;
        enableCompletion = lib.mkDefault true;
        autosuggestions = {
          enable = lib.mkDefault true;
          strategy = lib.mkDefault ["history"];
        };
      };
    };
  };
}
