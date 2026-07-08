{inputs, ...}: {
  flake.nixosModules.wonderland = {pkgs, ...}: {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      boot-efi
      boot-loader-grub
      cpu-amd
      disko-efi
      gpu-nvidia
      hardware-defaults
      hardware-nvme
      hardware-sd
      hardware-usb
      network-dns
      network-firewall
      network-interfaces
      service-ssh
      settings-audio
      settings-fonts
      settings-greetd
      settings-locale
      settings-nix
      settings-nixpkgs
      settings-wayland
      software-firefox
      software-homemanager
      software-networkmanager
      software-qemu
      software-sudo
      software-zsh
      # keep-sorted end
    ];

    # disko.devices.disk."main".device = "/dev/nvme0n1";
    disko.devices.disk."main".device = "/dev/sda";
    networking.hostName = "wonderland";

    # TODO: Extract into rice-wonderland module
    environment.systemPackages = with pkgs; [
      mako
      niri
      rofi
      swww
      tuigreet
      uwsm
      waybar
      xwayland-satellite
      nano
    ];

    fonts.packages = with pkgs; [
      fira-code
      fira-code-symbols
      font-awesome
    ];

    home-manager = {
      users.rabbit = {
        home.username = "rabbit";
        home.homeDirectory = "/home/rabbit";
        home.stateVersion = "25.05";
      };
      sharedModules = with inputs.self.homeManagerModules; [
        # keep-sorted start
        software-bat
        software-claude
        software-direnv
        software-discord
        software-gemini
        software-ghostty
        software-git
        software-lsd
        software-opencode
        software-spotify
        software-ssh
        software-starship
        software-vscode
        software-zoxide
        # keep-sorted end
      ];
    };

    programs = {
      dconf.enable = true;
      xwayland.enable = true;
    };

    # TODO: Move into rice-wonderland once that module exists
    services.greetd.settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
      user = "greeter";
    };

    services.xserver = {
      enable = true;
      xkb = {
        layout = "us,es";
        options = "grp:lalt_lshift_toggle";
      };
    };

    specialisation.gaming = {
      inheritParentConfig = true;
      configuration = {
        imports = with inputs.self.nixosModules; [rice-gaming];
        home-manager.sharedModules = with inputs.self.homeManagerModules; [
          rice-gaming
        ];
      };
    };

    users = {
      users.rabbit = {
        isNormalUser = true;
        initialPassword = "nixos";
        description = "White Rabbit";
        shell = pkgs.zsh;
        extraGroups = [
          "networkmanager"
          "sshusers"
          "wheel"
        ];
      };
    };

    # TODO: Move into rice-wonderland once that module exists
    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = ["gtk"];
          "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
          "org.freedesktop.impl.portal.RemoteDesktop" = ["gnome"];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      wlr.enable = true;
      xdgOpenUsePortal = true;
    };
  };

  flake.nixosConfigurations.wonderland = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.agenix.nixosModules.default
      inputs.self.nixosModules.wonderland
      {nixpkgs.hostPlatform = "x86_64-linux";}
    ];
  };
}
