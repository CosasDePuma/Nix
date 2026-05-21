{inputs, ...}: {
  flake.modules.nixos.wonderland = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      desktop-defaults
      boot-efi
      boot-loader-grub
      cpu-amd
      hardware-defaults
      gpu-nvidia
    ];

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
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      users.rabbit = {
        home.username = "rabbit";
        home.homeDirectory = "/home/rabbit";
        home.stateVersion = "25.05";
      };
      sharedModules = with inputs.self.modules.homeManager; [
        # --- settings
        cosasdepuma-settings
        # --- software
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
      ];
    };

    networking = {
      hostName = "wonderland";
      hostId = builtins.substring 0 8 (builtins.hashString "md5" "wonderland");
      networkmanager.enable = true;
      usePredictableInterfaceNames = false;
      domain = "home";
      search = ["home"];
      nameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      firewall = {
        enable = true;
        allowedTCPPorts = [22];
        allowedUDPPorts = [];
      };
    };

    programs = {
      dconf.enable = true;
      firefox.enable = true;
      xwayland.enable = true;
      zsh.enable = true;
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
        description = "White Rabbit";
        shell = pkgs.zsh;
        extraGroups = [
          "networkmanager"
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
      inputs.disko.nixosModules.default
      inputs.home-manager.nixosModules.default
      inputs.self.modules.nixos.wonderland
      ./_hardware-configuration.nix
      {nixpkgs.hostPlatform = "x86_64-linux";}
    ];
  };
}
