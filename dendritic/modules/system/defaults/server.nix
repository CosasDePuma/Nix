{inputs, ...}: {
  flake = {
    nixosModules.server-defaults = {config, ...}: {
      imports = with inputs.self.nixosModules; [
        service-ssh
        settings-locale
        settings-nix
        settings-nixpkgs
        system-impermanence
      ];

      age.identityPaths = builtins.map (key: key.path) config.services.openssh.hostKeys;

      boot.loader.grub.enable = true;

      disko.devices = {
        disk.disk0 = {
          device = "/dev/sda";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              BOOT = {
                size = "1M";
                type = "EF02";
              };
              NIXOS = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/nix";
                  extraArgs = [
                    "-L"
                    "NIXOS"
                  ];
                };
              };
            };
          };
        };
        nodev."/" = {
          fsType = "tmpfs";
          mountOptions = [
            "defaults"
            "size=2G"
            "mode=755"
          ];
        };
        nodev."/tmp".fsType = "tmpfs";
      };

      hardware.enableAllHardware = true;

      users = {
        mutableUsers = false;
        groups = {
          "sshuser" = {};
          "users" = {};
        };
      };
    };
  };
}
