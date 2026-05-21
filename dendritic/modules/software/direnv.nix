{lib, ...}: let
  direnv = config: {
    enable = lib.mkDefault true;
    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
    nix-direnv.enable = lib.mkDefault true;
    silent = lib.mkDefault true;
  };
in {
  flake.modules = {
    darwin.software-direnv = {
      homebrew.brews = ["direnv"];
    };

    homeManager.software-direnv = {osConfig, ...}: {
      programs.direnv = direnv osConfig;
    };

    nixos.software-direnv = {config, ...}: {
      programs.direnv = direnv config;
    };
  };
}
