{inputs, ...}: {
  flake.nixosModules.wonderland = {pkgs, ...}: {
    imports = with inputs.self.nixosModules; [
      # keep-sorted start
      boot-efi
      boot-loader-grub
      cpu-amd
      disko-efi
      hardware-defaults
      hardware-nvme
      hardware-sd
      hardware-usb
      gpu-nvidia
      network-dns
      network-interfaces
      network-firewall
      settings-locale
      settings-nix
      settings-nixpkgs
      software-homemanager
      software-networkmanager
      software-qemu
      software-sudo
      software-zsh
      # keep-sorted end
      service-ssh
    ];
    #disko.devices.disk."main".device = "/dev/nvme0n1";
    disko.devices.disk."main".device = "/dev/sda";
    networking.hostName = "wonderland";

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_SESSION_TYPE = "wayland";
      };
      systemPackages = with pkgs; [
        # wayland / desktop
        mako
        niri
        rofi
        swww
        tuigreet
        uwsm
        waybar
        xwayland-satellite
        # utilities
        nano
      ];
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        fira-code
        fira-code-symbols
        font-awesome
      ];
    };

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
      firefox.enable = true;
      xwayland.enable = true;
    };

    services = {
      dbus.enable = true;
      greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };
      pulseaudio.enable = false;
      xserver = {
        enable = true;
        xkb = {
          layout = "us,es";
          options = "grp:lalt_lshift_toggle";
        };
      };
    };

    specialisation.gaming = {
      inheritParentConfig = true;
      configuration = {
        environment = {
          sessionVariables = {
            GAMEMODERUNEXEC = "1";
            MANGOHUD = "1";
            PROTON_ENABLE_WAYLAND = "1";
            PROTON_USE_WINED3D = "0";
            SDL_VIDEODRIVER = "wayland";
            STEAM_USE_WAYLAND = "1";
          };
          systemPackages = with pkgs; [
            mangohud
            gamemode
            wayland
          ];
        };
        programs.steam = {
          dedicatedServer.openFirewall = true;
          enable = true;
          extraCompatPackages = with pkgs; [proton-ge-bin];
          remotePlay.openFirewall = true;
        };
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
      users.greeter = {
        isSystemUser = true;
        group = "greeter";
        description = "greetd greeter user";
      };
      groups.greeter = {};
    };

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
