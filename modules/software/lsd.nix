{lib, ...}: {
  flake.modules = {
    darwin.lsd-software = {
      homebrew.brews = ["lsd"];
    };

    homeManager.lsd-software = {osConfig, ...}: {
      programs.lsd = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault osConfig.programs.bash.enable;
        enableFishIntegration = lib.mkDefault osConfig.programs.fish.enable;
        enableZshIntegration = lib.mkDefault osConfig.programs.zsh.enable;
        settings.color.when = lib.mkDefault "always";
      };
    };

    nixos.lsd-software = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        lsd
      ];
    };
  };
}
