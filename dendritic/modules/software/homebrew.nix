{lib, ...}: {
  flake.darwinModules.software-homebrew = {
    homebrew = {
      enable = lib.mkDefault true;
      global = {
        autoUpdate = lib.mkDefault true;
        brewfile = lib.mkDefault true;
      };
      onActivation = {
        autoUpdate = lib.mkDefault true;
        cleanup = lib.mkDefault "zap";
      };
    };
    environment.variables.HOMEBREW_NO_ANALYTICS = lib.mkDefault "1";
  };
}
