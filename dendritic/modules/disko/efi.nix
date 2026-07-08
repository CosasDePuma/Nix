{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.disko-efi = {
    imports = [
      inputs.disko.nixosModules.default
      inputs.self.nixosModules.boot-efi
    ];
    config.disko.devices = {
      disk."main" = {
        type = lib.mkDefault "disk";
        content = {
          type = lib.mkDefault "gpt";
          partitions = {
            ESP = {
              size = lib.mkDefault "512M";
              type = lib.mkDefault "EF00";
              content = {
                type = lib.mkDefault "filesystem";
                format = lib.mkDefault "vfat";
                mountpoint = lib.mkDefault "/boot";
                mountOptions = lib.mkDefault [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            root = {
              size = lib.mkDefault "100%";
              content = {
                type = lib.mkDefault "filesystem";
                format = lib.mkDefault "ext4";
                mountpoint = lib.mkDefault "/";
                extraArgs = lib.mkDefault [
                  "-L"
                  "NIXOS"
                ];
              };
            };
          };
        };
      };
      nodev."/tmp" = {
        fsType = lib.mkDefault "tmpfs";
        mountOptions = lib.mkDefault [
          "noexec"
          "size=4G"
        ];
      };
    };
  };
}
