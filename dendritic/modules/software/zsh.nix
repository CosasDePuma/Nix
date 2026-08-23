{lib, ...}: {
  flake = {
    darwinModules.software-zsh = {
      homebrew.brews = ["zsh"];
    };

    homeManagerModules.software-zsh = {pkgs, ...}: {
      programs.zsh = {
        enable = lib.mkDefault true;
        enableCompletion = lib.mkDefault true;
        autosuggestion = {
          enable = lib.mkDefault true;
          strategy = lib.mkDefault ["history"];
        };
        loginExtra = lib.mkDefault ''
          if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
            exec ${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop
          fi
        '';
        shellGlobalAliases = {
          "--yolo" = lib.mkDefault "--dangerously-skip-permissions";
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
        shellAliases = {
          "--yolo" = lib.mkDefault "--dangerously-skip-permissions";
        };
      };
    };
  };
}
