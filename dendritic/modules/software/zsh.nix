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
        shellGlobalAliases = {
          "--yolo" = lib.mkDefault "--dangerously-skip-permissions";
        };
      };
    };

    nixosModules.software-zsh = {pkgs, ...}: {
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
      users.defaultUserShell = lib.mkForce pkgs.zsh;
    };
  };
}
