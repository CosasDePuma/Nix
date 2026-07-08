{lib, ...}: {
  flake = {
    darwinModules.software-zoxide = {
      homebrew.brews = ["zoxide"];
    };

    homeManagerModules.software-zoxide = {osConfig, ...}: {
      programs.zoxide = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault osConfig.programs.bash.enable;
        enableFishIntegration = lib.mkDefault osConfig.programs.fish.enable;
        enableZshIntegration = lib.mkDefault osConfig.programs.zsh.enable;
        options = lib.mkDefault ["--cmd cd"];
      };
    };

    nixosModules.software-zoxide = {config, ...}: {
      programs.zoxide = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault config.programs.bash.enable;
        enableFishIntegration = lib.mkDefault config.programs.fish.enable;
        enableZshIntegration = lib.mkDefault config.programs.zsh.enable;
        flags = lib.mkDefault ["--cmd cd"];
      };
    };
  };
}
