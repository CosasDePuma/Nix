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
    darwin.direnv-software = {
      homebrew.brews = ["direnv"];
    };

    homeManager.direnv-software = {osConfig, ...}: {
      programs.direnv = direnv osConfig;
    };

    nixos.direnv-software = {config, ...}: {
      programs.direnv = direnv config;
    };
  };
}
