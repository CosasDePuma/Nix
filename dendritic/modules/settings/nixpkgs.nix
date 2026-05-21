{lib, ...}: let
  settings-nixpkgs = {
    nixpkgs.config.allowUnfree = lib.mkDefault true;
  };
in {
  flake.modules = {
    darwin = {inherit settings-nixpkgs;};
    nixos = {inherit settings-nixpkgs;};
  };
}
