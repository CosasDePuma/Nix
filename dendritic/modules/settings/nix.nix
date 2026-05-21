{lib, ...}: {
  flake = {
    darwinModules.settings-nix = {
      nix = {
        enable = lib.mkDefault false;
        extraOptions = lib.mkDefault ''
          experimental-features = nix-command flakes
          extra-platforms = x86_64-darwin aarch64-darwin
        '';
        settings.auto-optimise-store = lib.mkDefault false;
      };
      stateVersion = lib.mkDefault 6;
    };

    nixosModules.settings-nix = {
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
          allowed-users = lib.mkDefault ["@wheel"];
          auto-optimise-store = lib.mkDefault true;
        };
      };
      system.stateVersion = lib.mkDefault "25.05";
    };
  };
}
