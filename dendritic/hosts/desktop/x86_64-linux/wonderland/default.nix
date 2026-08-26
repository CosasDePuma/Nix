{inputs, ...}: {
  flake.nixosModules.wonderland = {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      boot-efi
      boot-loader-grub
      cpu-amd
      disko-impermanence
      gpu-nvidia
      hardware-defaults
      hardware-nvme
      meta-ai
      meta-terminal
      rice-omarchy
      service-ssh
      settings-locale
      settings-nix
      software-brave
      software-homemanager
      software-networkmanager
      software-spotify
      software-vscode
      software-windowsvm
      system-impermanence
      # keep-sorted end
    ];

    home-manager.users.wizard = {
      home.stateVersion = "26.11";
      imports = with inputs.self.homeManagerModules; [
        # keep-sorted start
        meta-ai
        meta-terminal
        profile-cosasdepuma
        rice-omarchy
        software-brave
        software-spotify
        software-vscode
        software-windowsvm
        themes-everforest
        # keep-sorted end
      ];
    };

    disko.devices.disk.main.device = "/dev/disk/by-id/nvme-eui.0025384b51424d22";

    environment.persistence."/nix/persist".users.wizard = {
      directories = [
        # keep-sorted start
        ".claude"
        ".config"
        ".copilot"
        ".gemini"
        ".local"
        ".pi"
        ".ssh"
        ".vscode"
        "Documents"
        "Downloads"
        "Windows"
        # keep-sorted end
      ];
      files = [
        # keep-sorted start
        ".bash_history"
        ".zsh_history"
        # keep-sorted end
      ];
    };

    networking.hostName = "wonderland";

    system.stateVersion = "26.11";

    users.users.wizard = {
      initialPassword = "wizard";
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "audio" "sshusers" "docker"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKh1YtKaItcNzC3RGez38zaJ0geelyrb6AFV73OqLchv"
      ];
    };
  };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "wonderland";
}
