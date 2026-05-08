{ lib, ... }:
{
  flake.modules.darwin.homebrew-software = {
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
  };
}