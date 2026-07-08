{inputs, ...}: {
  flake.nixosModules.alchemy = {pkgs, ...}: {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      boot-efi
      boot-loader-grub
      cpu-amd
      disko-impermanence
      gpu-nvidia
      hardware-defaults
      hardware-nvme
      network-dns
      network-firewall
      network-interfaces
      rice-antiquary
      service-ssh
      settings-audio
      settings-fonts
      settings-greetd
      settings-locale
      settings-nix
      settings-nixpkgs
      settings-wayland
      software-firefox
      software-git
      software-homemanager
      software-hyprland
      software-networkmanager
      software-nyxt
      software-spotify
      software-sudo
      software-vscode
      software-zsh
      system-impermanence
      # keep-sorted end
    ];

    disko.devices.disk."main".device = "/dev/nvme0n1";
    networking.hostName = "alchemy";
    environment.persistence."/nix/persist".users."wizard".directories = [
      # keep-sorted start
      ".config"
      ".local"
      ".ssh"
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Videos"
      # keep-sorted end
    ];

    fonts.packages = with pkgs; [
      maple-mono.NF
      nerd-fonts.symbols-only
    ];

    home-manager = {
      users."wizard" = {
        home.username = "wizard";
        home.homeDirectory = "/home/wizard";
        home.stateVersion = "26.05";
      };
      sharedModules = with inputs.self.homeManagerModules; [
        # keep-sorted start
        rice-antiquary
        software-antigravity
        software-bat
        software-claude
        software-git
        software-hyprland
        software-lsd
        software-nyxt
        software-opencode
        software-spotify
        software-vscode
        software-zoxide
        software-zsh
        # keep-sorted end
      ];
    };

    services.greetd.settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
      user = "greeter";
    };

    security.pam.sshAgentAuth.enable = true;
    security.pam.services.sudo.sshAgentAuth = true;
    security.sudo.extraConfig = ''
      Defaults    env_keep+="SSH_AUTH_SOCK"
    '';

    users.users.wizard = {
      isNormalUser = true;
      initialPassword = "nixos";
      description = "Wizard";
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

    # ── Specialisations ──────────────────────────────────────────────────────

    specialisation.gaming = {
      inheritParentConfig = true;
      configuration = {
        imports = with inputs.self.nixosModules; [rice-gaming];
        home-manager.sharedModules = with inputs.self.homeManagerModules; [
          rice-gaming
        ];
      };
    };

    specialisation.work = {
      inheritParentConfig = true;
      configuration = {
        imports = with inputs.self.nixosModules; [
          rice-retro
          software-openconnect
          software-qemu
          software-teams
        ];
        home-manager.sharedModules = with inputs.self.homeManagerModules; [
          rice-retro
        ];
      };
    };
  };

  flake.nixosConfigurations.alchemy = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.agenix.nixosModules.default
      inputs.self.nixosModules.alchemy
      {nixpkgs.hostPlatform = "x86_64-linux";}
    ];
  };
}
