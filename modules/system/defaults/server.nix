{inputs, ...}: {
  flake.modules.nixos.server-defaults = {config, ...}: {
    imports = with inputs.self.modules.nixos; [
      ssh-service
      system-defaults
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
                mountpoint = "/";
                extraArgs = [
                  "-L"
                  "NIXOS"
                ];
              };
            };
          };
        };
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
}
