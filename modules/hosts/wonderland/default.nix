{ inputs, ... }:
{
  flake.modules.nixos.wonderland =
    { config, pkgs, lib, ... }:
    {
      imports = [
        inputs.self.modules.nixos.system-default
      ];

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        kernelParams = [ "nvidia-drm.modeset=1" ];
      };

      environment = {
        sessionVariables = {
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
          LIBVA_DRIVER_NAME = "nvidia";
          NIXOS_OZONE_WL = "1";
          XDG_SESSION_TYPE = "wayland";
        };
        systemPackages = with pkgs; [
          ghostty
          mako
          niri
          rofi
          swww
          tuigreet
          uwsm
          waybar
          xwayland-satellite
          bat
          direnv
          git
          lsd
          nano
          starship
          zoxide
          opencode
          vscode
          discord
          spotify
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

      hardware = {
        enableAllHardware = true;
        cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        nvidia = {
          modesetting.enable = true;
          package = config.boot.kernelPackages.nvidiaPackages.latest;
          powerManagement.enable = false;
          powerManagement.finegrained = false;
          open = true;
          nvidiaSettings = true;
        };
        graphics = {
          enable = true;
          enable32Bit = true;
        };
      };

      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "es_ES.UTF-8";
          LC_IDENTIFICATION = "es_ES.UTF-8";
          LC_MEASUREMENT = "es_ES.UTF-8";
          LC_MONETARY = "es_ES.UTF-8";
          LC_NAME = "es_ES.UTF-8";
          LC_NUMERIC = "es_ES.UTF-8";
          LC_PAPER = "es_ES.UTF-8";
          LC_TELEPHONE = "es_ES.UTF-8";
          LC_TIME = "es_ES.UTF-8";
        };
      };

      networking = {
        hostName = "wonderland";
        hostId = builtins.substring 0 8 (builtins.hashString "md5" "wonderland");
        networkmanager.enable = true;
        usePredictableInterfaceNames = false;
        domain = "home";
        search = [ "home" ];
        nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        firewall = {
          enable = true;
          allowedTCPPorts = [ 22 ];
          allowedUDPPorts = [ ];
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
          videoDrivers = [ "nvidia" ];
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
            extraCompatPackages = with pkgs; [ proton-ge-bin ];
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
        groups.greeter = { };
      };

      xdg.portal = {
        enable = true;
        config = {
          common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
            "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
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
      inputs.disko.nixosModules.default
      inputs.agenix.nixosModules.default
      inputs.self.modules.nixos.wonderland
      ./_hardware-configuration.nix
      { nixpkgs.hostPlatform = "x86_64-linux"; }
    ];
  };
}
