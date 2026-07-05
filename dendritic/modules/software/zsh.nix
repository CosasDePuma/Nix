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
        loginExtra = lib.mkDefault ''
          if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
            exec start-hyprland
          fi
        '';
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
