{ lib, ... }:
{
  flake.modules.nixos.nixpkgs-settings = {
    nixpkgs.config.allowUnfree = lib.mkDefault true;
  };
}
