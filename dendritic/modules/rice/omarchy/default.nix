{
  inputs,
  lib,
  ...
}: {
  flake = {
    homeManagerModules.rice-omarchy = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        inputs.self.homeManagerModules.software-hyprland
        inputs.self.homeManagerModules.software-quickshell
        inputs.self.homeManagerModules.settings-wayland
        inputs.self.homeManagerModules.software-warp
        inputs.self.homeManagerModules.software-starship
        inputs.self.homeManagerModules.software-swaybg
      ];

      # Environment variables for Omarchy desktop ecosystem
      home.sessionVariables = {
        OMARCHY_PATH = lib.mkDefault "${config.home.homeDirectory}/.config/omarchy";
        TERMINAL = lib.mkDefault "warp-terminal";
        XDG_CURRENT_DESKTOP = lib.mkDefault "Hyprland";
        XDG_SESSION_DESKTOP = lib.mkDefault "Hyprland";
      };

      # Hyprland custom configuration in Omarchy style
      wayland.windowManager.hyprland = {
        enable = lib.mkDefault true;
        settings = {
          config = {
            general = {
              gaps_in = lib.mkDefault 6;
              gaps_out = lib.mkDefault 12;
              border_size = lib.mkDefault 2;
              "col.active_border" = lib.mkDefault (
                lib.generators.mkLuaInline ''{colors = {"rgba(7aa2f7ee)", "rgba(bb9af7ee)"}, angle = 45}''
              );
              "col.inactive_border" = lib.mkDefault "rgba(414868aa)";
              layout = lib.mkDefault "dwindle";
            };

            decoration = {
              rounding = lib.mkDefault 10;
              blur = {
                enabled = lib.mkDefault true;
                size = lib.mkDefault 6;
                passes = lib.mkDefault 2;
              };
              shadow = {
                enabled = lib.mkDefault true;
                range = lib.mkDefault 15;
                render_power = lib.mkDefault 3;
              };
            };
          };

          bind = [
            {_args = ["SUPER + RETURN" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("warp-terminal")'')];}
            {_args = ["SUPER + SPACE" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("omarchy-menu")'')];}
            {_args = ["SUPER + V" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("omarchy-menu-clipboard")'')];}
            {_args = ["SUPER + COMMA" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("omarchy-theme-switcher")'')];}
            {_args = ["SUPER + ESCAPE" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("omarchy-system-lock")'')];}
          ];
        };
      };

      # Quickshell layout deployment
      xdg.configFile."omarchy/shell.json".text = builtins.toJSON {
        version = 1;
        idle = {
          screensaver = 150;
          lock = 300;
        };
        bar = {
          position = "top";
          transparent = false;
          centerAnchor = "omarchy.clock";
          layout = {
            left = [
              {id = "omarchy.menu";}
              {id = "omarchy.workspaces";}
            ];
            center = [
              {id = "omarchy.indicators";}
              {
                id = "omarchy.clock";
                format = "dddd HH:mm";
                formatAlt = "d MMMM 'W'ww yyyy";
                verticalFormat = "HH\n—\nmm";
              }
              {id = "omarchy.keyboard-layout";}
              {id = "omarchy.weather";}
              {id = "omarchy.system-update";}
            ];
            right = [
              {id = "omarchy.tray";}
              {id = "omarchy.agents";}
              {id = "omarchy.bluetooth";}
              {id = "omarchy.network";}
              {id = "omarchy.audio";}
              {id = "omarchy.monitor";}
              {id = "omarchy.power";}
            ];
          };
        };
        plugins = [];
      };

      # Omarchy essential tools in user space
      home.packages = with pkgs; [
        brightnessctl
        fzf
        grim
        gum
        hypridle
        hyprlock
        hyprsunset
        imagemagick
        jq
        libnotify
        pamixer
        playerctl
        slurp
        swaybg
        wireplumber
        wl-clipboard
      ];
    };

    nixosModules.rice-omarchy = {
      pkgs,
      lib,
      ...
    }: {
      imports = [
        inputs.self.nixosModules.software-hyprland
        inputs.self.nixosModules.software-quickshell
        inputs.self.nixosModules.settings-wayland
        inputs.self.nixosModules.software-warp
        inputs.self.nixosModules.software-starship
        inputs.self.nixosModules.software-swaybg
        inputs.self.nixosModules.fonts-jetbrains
        inputs.self.nixosModules.fonts-firacode
      ];

      # System level services for Omarchy rice
      security.pam.services.hyprlock = {};
      services = {
        # greetd + tuigreet: a terminal greeter holds no seat/DRM master, so
        # Hyprland can take the GPU. GDM's Wayland greeter races the session
        # for DRM ("Session never registered") and GNOME 50 no longer allows
        # switching it to X11.
        greetd = {
          enable = lib.mkDefault true;
          settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --sessions /run/current-system/sw/share/wayland-sessions --remember";
        };
        upower.enable = lib.mkDefault true;
      };
      hardware.bluetooth.enable = lib.mkDefault true;

      # System packages available globally
      environment.systemPackages = with pkgs; [
        brightnessctl
        fzf
        grim
        gum
        hypridle
        hyprlock
        hyprsunset
        jq
        libnotify
        pamixer
        playerctl
        slurp
        swaybg
        wireplumber
        wl-clipboard
      ];
    };
  };
}
