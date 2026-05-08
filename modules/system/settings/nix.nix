{ lib, ... }:
{
  flake.modules = {
    darwin.nix-settings = {
      nix = {
        enable = lib.mkDefault false;
        extraOptions = lib.mkDefault ''
          experimental-features = nix-command flakes
          extra-platforms = x86_64-darwin aarch64-darwin
        '';
        settings.auto-optimise-store = lib.mkDefault false;
      };
    };

    nixos.nix-settings = {
      nix = {
        extraOptions = lib.mkDefault ''
          experimental-features = nix-command flakes
        '';
        gc = {
          automatic = lib.mkDefault true;
          dates = lib.mkDefault "weekly";
          options = lib.mkDefault "--delete-older-than 7d";
          persistent = lib.mkDefault true;
        };
        settings = {
          allowed-users = lib.mkDefault [ "@wheel" ];
          auto-optimise-store = lib.mkDefault true;
        };
      };
    };
  };
}
