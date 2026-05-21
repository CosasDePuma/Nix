{lib, ...}: {
  flake = {
    darwinModules.software-lsd = {
      homebrew.brews = ["lsd"];
    };

    homeManagerModules.software-lsd = {osConfig, ...}: {
      programs.lsd = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault osConfig.programs.bash.enable;
        enableFishIntegration = lib.mkDefault osConfig.programs.fish.enable;
        enableZshIntegration = lib.mkDefault osConfig.programs.zsh.enable;
        settings.color.when = lib.mkDefault "always";
      };
    };

    nixosModules.software-lsd = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [lsd];
    };
  };
}
