{inputs, ...}: {
  flake.nixosModules.antiquary = {pkgs, ...}: {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      boot-efi
      boot-loader-grub
      cpu-amd
      disko-impermanence
      gpu-nvidia
      hardware-defaults
      network-dns
      network-firewall
      network-interfaces
      rice-antiquity
      service-ssh
      settings-locale
      settings-nix
      settings-nixpkgs
      software-homemanager
      software-networkmanager
      software-qemu
      software-sudo
      software-zsh
      system-impermanence
      # keep-sorted end
    ];
    disko.devices.disk."main".device = "/dev/sda";
    networking.hostName = "antiquary";

    environment.persistence."/nix/persist" = {
      users.nixos = {
        directories = [
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          ".config"
          ".local"
          ".ssh"
        ];
      };
    };

    home-manager = {
      users.nixos = {
        home.username = "nixos";
        home.homeDirectory = "/home/nixos";
        home.stateVersion = "25.05";
      };
      sharedModules = with inputs.self.homeManagerModules; [
        # keep-sorted start
        rice-antiquity
        software-bat
        software-git
        software-lsd
        software-zoxide
        software-zsh
        # keep-sorted end
      ];
    };

    security.pam.sshAgentAuth.enable = true;
    security.pam.services.sudo.sshAgentAuth = true;
    security.sudo.extraConfig = ''
      Defaults    env_keep+="SSH_AUTH_SOCK"
    '';

    users = {
      users.nixos = {
        isNormalUser = true;
        initialPassword = "nixos";
        description = "NixOS User";
        shell = pkgs.zsh;
        extraGroups = [
          "networkmanager"
          "sshusers"
          "wheel"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKh1YtKaItcNzC3RGez38zaJ0geelyrb6AFV73OqLchv"
        ];
      };
    };
  };

  flake.nixosConfigurations.antiquary = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.agenix.nixosModules.default
      inputs.self.nixosModules.antiquary
      {nixpkgs.hostPlatform = "x86_64-linux";}
    ];
  };
}
