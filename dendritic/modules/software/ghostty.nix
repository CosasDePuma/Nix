{lib, ...}: {
  flake.modules = {
    darwin.software-ghostty = {
      homebrew.casks = ["ghostty"];
    };

    homeManager.software-ghostty = {osConfig, ...}: {
      programs.ghostty = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault osConfig.programs.bash.enable;
        enableFishIntegration = lib.mkDefault osConfig.programs.fish.enable;
        enableZshIntegration = lib.mkDefault osConfig.programs.zsh.enable;
        settings = {
          font-family = lib.mkDefault "FiraCode Nerd Font Mono";
          font-feature = lib.mkDefault "+liga";
          font-size = lib.mkDefault 15;
          font-thicken = lib.mkDefault true;
          term = lib.mkDefault "xterm-256color";
          window-padding-x = lib.mkDefault 20;
          window-padding-y = lib.mkDefault 10;
        };
      };
    };

    nixos.software-ghostty = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        ghostty
      ];
    };
  };
}
