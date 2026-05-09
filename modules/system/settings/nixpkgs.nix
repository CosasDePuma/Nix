{lib, ...}: let
  nixpkgs-settings = {
    nixpkgs.config.allowUnfree = lib.mkDefault true;
  };
in {
  flake.modules = {
    darwin = {inherit nixpkgs-settings;};
    nixos = {inherit nixpkgs-settings;};
  };
}
