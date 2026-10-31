{lib, ...}: {
  flake = {
    darwinModules.settings-nix = {
      nix = {
        enable = lib.mkDefault false;
        settings = {
          auto-optimise-store = lib.mkDefault false;
          experimental-features = ["nix-command" "flakes"];
          extra-platforms = ["aarch64-darwin"];
          warn-dirty = lib.mkDefault false;
        };
      };
      # nix.enable is off, so nix-darwin's nix.gc / nix.optimise are unavailable;
      # schedule the same housekeeping directly against the installer's Nix.
      launchd.daemons = {
        nix-gc.serviceConfig = {
          ProgramArguments = ["/nix/var/nix/profiles/default/bin/nix-collect-garbage" "--delete-older-than" "7d"];
          StartCalendarInterval = lib.mkDefault [
            {
              Weekday = 0;
              Hour = 3;
              Minute = 15;
            }
          ];
          StandardErrorPath = lib.mkDefault "/var/log/nix-gc.log";
          StandardOutPath = lib.mkDefault "/var/log/nix-gc.log";
        };
        nix-optimise.serviceConfig = {
          ProgramArguments = ["/nix/var/nix/profiles/default/bin/nix-store" "--optimise"];
          StartCalendarInterval = lib.mkDefault [
            {
              Weekday = 0;
              Hour = 4;
              Minute = 15;
            }
          ];
          StandardErrorPath = lib.mkDefault "/var/log/nix-optimise.log";
          StandardOutPath = lib.mkDefault "/var/log/nix-optimise.log";
        };
      };
      nixpkgs.config.allowUnfree = lib.mkDefault true;
      system.stateVersion = lib.mkDefault 6;
    };

    nixosModules.settings-nix = {options, ...}: {
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
          warn-dirty = lib.mkDefault false;
        };
      };
      # A system handed an external pkgs instance (e.g. a microVM sharing its
      # host's) must not set nixpkgs.config; it inherits the host's instead.
      nixpkgs = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
        config.allowUnfree = lib.mkDefault true;
      };
      system.stateVersion = lib.mkDefault "26.11";
    };
  };
}
