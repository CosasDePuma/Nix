{inputs, ...}: {
  flake.nixosModules.wonderland = {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      hardware-defaults
      meta-ai
      service-ssh
      settings-nix
      # keep-sorted end
    ];

    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    };

    disko.devices.disk.main = {
      device = "/dev/disk/by-id/nvme-eui.0025384b51424d22";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = ["-L" "NIXOS"];
            };
          };
        };
      };
    };

    i18n.defaultLocale = "en_US.UTF-8";

    networking = {
      hostName = "wonderland";
      networkmanager.enable = true;
    };

    services = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      openssh.settings.PasswordAuthentication = true;
      xserver.enable = true;
    };

    system.stateVersion = "26.11";

    time.timeZone = "Europe/Madrid";

    users.users.wizard = {
      initialPassword = "wizard";
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "audio" "sshusers"];
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "wonderland";
}
