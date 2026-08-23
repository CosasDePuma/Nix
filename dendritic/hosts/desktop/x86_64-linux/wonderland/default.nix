{inputs, ...}: {
  flake.nixosModules.wonderland = {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      boot-efi
      boot-loader-grub
      disko-impermanence
      hardware-defaults
      hardware-nvme
      meta-ai
      rice-omarchy
      service-ssh
      settings-locale
      settings-nix
      software-homemanager
      software-networkmanager
      system-impermanence
      # keep-sorted end
    ];

    home-manager.users.wizard = {
      home.stateVersion = "26.11";
      imports = with inputs.self.homeManagerModules; [
        # keep-sorted start
        meta-ai
        meta-terminal
        rice-omarchy
        # keep-sorted end
      ];
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

    networking.hostName = "wonderland";

    services.openssh.settings.PasswordAuthentication = true;

    system.stateVersion = "26.11";

    users.users.wizard = {
      initialPassword = "wizard";
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "audio" "sshusers"];
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "wonderland";
}
