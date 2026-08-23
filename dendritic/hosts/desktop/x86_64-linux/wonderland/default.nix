{inputs, ...}: {
  flake.nixosModules.wonderland = {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      disko-impermanence
      hardware-defaults
      hardware-nvme
      meta-ai
      service-ssh
      settings-nix
      system-impermanence
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

    disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.0025384b51424d22";

    environment.persistence."/nix/persist".users.wizard.directories = [
      "Downloads"
      "Documents"
      "Music"
      "Pictures"
      "Videos"
      ".config"
      ".local"
      ".ssh"
    ];

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
