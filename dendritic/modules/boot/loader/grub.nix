{lib, ...}: {
  flake.modules = {
    nixos.boot-loader-grub = {config, ...}: {
      boot.loader.grub = {
        enable = lib.mkDefault true;
        efiSupport = lib.mkDefault config.boot.loader.efi.canTouchEfiVariables;
        device = lib.mkDefault (
          if config.boot.loader.grub.efiSupport
          then "nodev"
          else "/dev/sda"
        );
      };
    };
  };
}
