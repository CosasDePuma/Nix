{lib, ...}: {
  flake = {
    darwinModules.settings-nix = {
      nix = {
        enable = lib.mkDefault false;
        settings = {
          auto-optimise-store = lib.mkDefault false;
          experimental-features = ["nix-command" "flakes"];
          extra-platforms = ["aarch64-darwin"];
        };
      };
      system.stateVersion = lib.mkDefault 6;
    };

    nixosModules.settings-nix = {
      nix = {
        gc = {
          automatic = lib.mkDefault true;
          dates = lib.mkDefault "weekly";
          options = lib.mkDefault "--delete-older-than 7d";
          persistent = lib.mkDefault true;
        };
        settings = {
          allowed-users = ["@wheel"];
          auto-optimise-store = lib.mkDefault true;
          experimental-features = ["nix-command" "flakes"];
        };
      };
      system.stateVersion = lib.mkDefault "26.05";
    };
  };
}
