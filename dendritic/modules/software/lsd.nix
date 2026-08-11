{lib, ...}: {
  flake = {
    darwinModules.software-lsd = {
      homebrew.brews = ["lsd"];
    };

    homeManagerModules.software-lsd = {
      pkgs,
      osConfig,
      ...
    }: {
      programs.lsd = {
        enable = lib.mkDefault true;
        enableBashIntegration = lib.mkDefault osConfig.programs.bash.enable;
        enableFishIntegration = lib.mkDefault osConfig.programs.fish.enable;
        enableZshIntegration = lib.mkDefault osConfig.programs.zsh.enable;
        settings.color.when = lib.mkDefault "always";
      };
      programs.zsh.shellAliases = {
        ls = lib.mkDefault "${pkgs.lsd}/bin/lsd --color=always";
        l = lib.mkDefault "${pkgs.lsd}/bin/lsd --color=always -l";
        ll = lib.mkDefault "${pkgs.lsd}/bin/lsd --color=always -al";
        la = lib.mkDefault "${pkgs.lsd}/bin/lsd --color=always -a";
      };
    };

    nixosModules.software-lsd = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [lsd];
      programs.zsh.shellAliases = {
        ls = lib.mkDefault "${pkgs.lsd}/bin/lsd --color=always";
        l = lib.mkDefault "${pkgs.lsd}/bin/lsd --color=always -l";
        ll = lib.mkDefault "${pkgs.lsd}/bin/lsd --color=always -al";
        la = lib.mkDefault "${pkgs.lsd}/bin/lsd --color=always -a";
      };
    };
  };
}
