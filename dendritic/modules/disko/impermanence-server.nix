{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.disko-impermanence-server = {
    imports = [
      inputs.disko.nixosModules.default
    ];
    config = {
      boot.loader.grub.enable = true;
      fileSystems."/nix".neededForBoot = lib.mkDefault true;
      disko.devices = {
        disk."main" = {
          device = lib.mkDefault "/dev/sda";
          type = lib.mkDefault "disk";
          content = {
            type = lib.mkDefault "gpt";
            partitions = {
              BOOT = {
                size = lib.mkDefault "1M";
                type = lib.mkDefault "EF02";
              };
              BOOT_FS = {
                size = lib.mkDefault "1G";
                content = {
                  type = lib.mkDefault "filesystem";
                  format = lib.mkDefault "ext4";
                  mountpoint = lib.mkDefault "/boot";
                };
              };
              NIXOS = {
                size = lib.mkDefault "100%";
                content = {
                  type = lib.mkDefault "filesystem";
                  format = lib.mkDefault "ext4";
                  mountpoint = lib.mkDefault "/nix";
                  mountOptions = lib.mkDefault ["defaults"];
                  extraArgs = lib.mkDefault [
                    "-L"
                    "NIXOS"
                  ];
                };
              };
            };
          };
        };
        nodev."/" = {
          fsType = lib.mkDefault "tmpfs";
          mountOptions = lib.mkDefault [
            "defaults"
            "size=2G"
            "mode=755"
          ];
        };
        nodev."/tmp" = {
          fsType = lib.mkDefault "tmpfs";
        };
      };
    };
  };
}
