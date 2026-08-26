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
    }: let
      omarchy-menu = import ./_scripts/omarchy-menu.nix {inherit pkgs;};
      omarchy-menu-clipboard = import ./_scripts/omarchy-menu-clipboard.nix {inherit pkgs;};
      omarchy-system-lock = import ./_scripts/omarchy-system-lock.nix {inherit pkgs;};
      omarchy-audio-output-sink = import ./_scripts/omarchy-audio-output-sink.nix {inherit pkgs;};
      theme-switcher = import ../../themes/_/theme-switcher.nix {inherit pkgs;};
    in {
      imports = [
        inputs.self.homeManagerModules.fonts-jetbrains
        inputs.self.homeManagerModules.settings-gtk
        inputs.self.homeManagerModules.software-hyprland
        inputs.self.homeManagerModules.software-mako
        inputs.self.homeManagerModules.software-omarchy-shell
        inputs.self.homeManagerModules.software-quickshell
        inputs.self.homeManagerModules.settings-wayland
        inputs.self.homeManagerModules.software-ghostty
        inputs.self.homeManagerModules.software-starship
        inputs.self.homeManagerModules.software-swaybg
      ];

      # Environment variables for Omarchy desktop ecosystem. OMARCHY_PATH
      # itself is owned by software-omarchy-shell (it points at the
      # vendored shell app, not this ~/.config/omarchy config dir).
      home.sessionVariables = {
        TERMINAL = lib.mkDefault "${pkgs.ghostty}/bin/ghostty";
        XDG_CURRENT_DESKTOP = lib.mkDefault "Hyprland";
        XDG_SESSION_DESKTOP = lib.mkDefault "Hyprland";
      };

      programs.fuzzel = {
        enable = lib.mkDefault true;
        settings.main.include = lib.mkDefault "${config.home.homeDirectory}/.local/state/theme/fuzzel.ini";
      };

      # Mirrors omarchy's install/user/first-run/gnome-theme.sh (gsettings
      # gtk-theme Adwaita-dark / icon-theme Yaru-blue / color-scheme
      # prefer-dark). colorScheme = "dark" is what actually makes Adwaita
      # render dark (the separate "Adwaita-dark" theme name upstream sets is
      # a legacy GTK3 alias for the same thing). settings-gtk owns turning
      # the gtk module on in the first place; this just picks the theme.
      gtk = {
        theme.name = lib.mkDefault "Adwaita";
        colorScheme = lib.mkDefault "dark";
        iconTheme = {
          name = lib.mkDefault "Yaru-blue";
          package = lib.mkDefault pkgs.yaru-theme;
        };
      };

      programs.ghostty = {
        enable = lib.mkDefault true;
        settings = {
          config-file = [
            "?${config.home.homeDirectory}/.local/state/theme/ghostty.conf"
          ];
          font-family = "JetBrainsMono Nerd Font";
          font-size = 9;
          window-padding-x = 14;
          window-padding-y = 14;
          gtk-single-instance = false;
          confirm-close-surface = lib.mkDefault false;
          resize-overlay = lib.mkDefault "never";
          gtk-toolbar-style = lib.mkDefault "flat";
          cursor-style = lib.mkDefault "block";
          cursor-style-blink = lib.mkDefault false;
          shell-integration-features = lib.mkDefault "no-cursor,ssh-env";
          mouse-scroll-multiplier = lib.mkDefault 0.95;
          async-backend = lib.mkDefault "epoll";
          keybind = [
            "shift+insert=paste_from_clipboard"
            "control+insert=copy_to_clipboard"
            "shift+enter=csi:13;2u"
            "alt+shift+enter=csi:13;4u"
            "super+control+shift+alt+arrow_down=resize_split:down,100"
            "super+control+shift+alt+arrow_up=resize_split:up,100"
            "super+control+shift+alt+arrow_left=resize_split:left,100"
            "super+control+shift+alt+arrow_right=resize_split:right,100"
          ];
        };
      };

      # Hyprland custom configuration in Omarchy style
      wayland.windowManager.hyprland = {
        enable = lib.mkDefault true;
        extraConfig = lib.mkDefault ''
          pcall(dofile, os.getenv("HOME") .. "/.local/state/theme/hyprland.lua")
        '';
        settings = {
          config = {
            general = {
              gaps_in = lib.mkDefault 6;
              gaps_out = lib.mkDefault 12;
              border_size = lib.mkDefault 2;
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

          # bind is a list: this fully replaces software-hyprland's mkDefault
          # one instead of merging with it (Hyprland fires every bind that
          # matches a key, so a merge would double-fire duplicates like
          # SUPER+RETURN). That means every generic binding a rice still
          # wants has to be repeated here, not just the omarchy-specific
          # ones.
          bind = [
            # --- omarchy
            {_args = ["SUPER + RETURN" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.ghostty}/bin/ghostty")'')];}
            {_args = ["SUPER + SHIFT + RETURN" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("$TERMINAL -e ${inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/herdr")'')];}
            {_args = ["SUPER + SPACE" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${omarchy-menu}/bin/omarchy-menu")'')];}
            {_args = ["SUPER + V" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${omarchy-menu-clipboard}/bin/omarchy-menu-clipboard")'')];}
            {_args = ["SUPER + COMMA" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${theme-switcher}/bin/theme-switcher")'')];}
            {_args = ["SUPER + ESCAPE" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${omarchy-system-lock}/bin/omarchy-system-lock")'')];}
            {_args = ["SUPER + B" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${lib.getExe pkgs.brave-origin}")'')];}

            # --- window management
            {_args = ["SUPER + Q" (lib.generators.mkLuaInline "hl.dsp.window.close()")];}
            {_args = ["SUPER + SHIFT + SPACE" (lib.generators.mkLuaInline ''hl.dsp.window.float({action = "toggle"})'')];}
            {_args = ["SUPER + F" (lib.generators.mkLuaInline "hl.dsp.window.fullscreen()")];}

            # --- focus, between windows
            {_args = ["SUPER + LEFT" (lib.generators.mkLuaInline ''hl.dsp.focus({direction = "left"})'')];}
            {_args = ["SUPER + RIGHT" (lib.generators.mkLuaInline ''hl.dsp.focus({direction = "right"})'')];}
            {_args = ["SUPER + UP" (lib.generators.mkLuaInline ''hl.dsp.focus({direction = "up"})'')];}
            {_args = ["SUPER + DOWN" (lib.generators.mkLuaInline ''hl.dsp.focus({direction = "down"})'')];}

            # --- workspaces
            {_args = ["SUPER + 1" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "1"})'')];}
            {_args = ["SUPER + SHIFT + 1" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "1", follow = true})'')];}
            {_args = ["SUPER + 2" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "2"})'')];}
            {_args = ["SUPER + SHIFT + 2" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "2", follow = true})'')];}
            {_args = ["SUPER + 3" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "3"})'')];}
            {_args = ["SUPER + SHIFT + 3" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "3", follow = true})'')];}
            {_args = ["SUPER + 4" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "4"})'')];}
            {_args = ["SUPER + SHIFT + 4" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "4", follow = true})'')];}
            {_args = ["SUPER + 5" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "5"})'')];}
            {_args = ["SUPER + SHIFT + 5" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "5", follow = true})'')];}
            {_args = ["SUPER + 6" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "6"})'')];}
            {_args = ["SUPER + SHIFT + 6" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "6", follow = true})'')];}
            {_args = ["SUPER + 7" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "7"})'')];}
            {_args = ["SUPER + SHIFT + 7" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "7", follow = true})'')];}
            {_args = ["SUPER + 8" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "8"})'')];}
            {_args = ["SUPER + SHIFT + 8" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "8", follow = true})'')];}
            {_args = ["SUPER + 9" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "9"})'')];}
            {_args = ["SUPER + SHIFT + 9" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "9", follow = true})'')];}
            {_args = ["SUPER + 0" (lib.generators.mkLuaInline ''hl.dsp.focus({workspace = "10"})'')];}
            {_args = ["SUPER + SHIFT + 0" (lib.generators.mkLuaInline ''hl.dsp.window.move({workspace = "10", follow = true})'')];}

            # --- media keys
            {_args = ["XF86AudioRaiseVolume" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")'') {repeating = true;}];}
            {_args = ["XF86AudioLowerVolume" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'') {repeating = true;}];}
            {_args = ["XF86AudioMute" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')];}
            {_args = ["XF86AudioMicMute" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'')];}
            {_args = ["XF86MonBrightnessUp" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl s 10%+")'') {repeating = true;}];}
            {_args = ["XF86MonBrightnessDown" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl s 10%-")'') {repeating = true;}];}

            # --- mouse
            {
              _args = [
                "SUPER + mouse:272"
                (lib.generators.mkLuaInline "hl.dsp.window.drag()")
                {
                  mouse = true;
                  drag = true;
                }
              ];
            }
            {
              _args = [
                "SUPER + mouse:273"
                (lib.generators.mkLuaInline "hl.dsp.window.resize()")
                {
                  mouse = true;
                  drag = true;
                }
              ];
            }
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
      home.packages =
        [
          omarchy-audio-output-sink
          omarchy-menu
          omarchy-menu-clipboard
          omarchy-system-lock
          theme-switcher
        ]
        ++ (with pkgs; [
          brightnessctl
          fzf
          grim
          gum
          # hyprsunset stays: the shell's nightlight plugin drives it via
          # hyprctl hyprsunset temperature.
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
        ]);

      xdg.configFile."herdr/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/state/theme/herdr.toml";

      # services.mako only installs the package and writes the config; it
      # starts nothing on its own, so notify-send has no D-Bus name to
      # reach without this unit.
      systemd.user.services.mako = {
        Unit = {
          Description = "Mako notification daemon";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          # uwsm imports WAYLAND_DISPLAY into the systemd user manager after
          # activating the target, so the first start(s) can race it. Widen
          # the burst window instead of failing permanently.
          StartLimitIntervalSec = 60;
          StartLimitBurst = 10;
        };
        Service = {
          ExecStart = "${config.services.mako.package}/bin/mako -c %h/.local/state/theme/mako.conf";
          Restart = "on-failure";
          RestartSec = "2s";
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      systemd.user.services.wallpaper = {
        Unit = {
          Description = "Wallpaper";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          StartLimitIntervalSec = 60;
          StartLimitBurst = 10;
        };
        Service = {
          ExecStart = "${pkgs.swaybg}/bin/swaybg -i %h/.local/state/theme/wallpaper -m fill";
          Restart = "on-failure";
          RestartSec = "2s";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };

    nixosModules.rice-omarchy = {pkgs, ...}: {
      imports = [
        inputs.self.nixosModules.hardware-bluetooth
        inputs.self.nixosModules.service-greetd
        inputs.self.nixosModules.service-omarchy-lock
        inputs.self.nixosModules.service-upower
        inputs.self.nixosModules.settings-gtk
        inputs.self.nixosModules.software-hyprland
        inputs.self.nixosModules.software-mako
        inputs.self.nixosModules.software-quickshell
        inputs.self.nixosModules.settings-wayland
        inputs.self.nixosModules.software-ghostty
        inputs.self.nixosModules.software-starship
        inputs.self.nixosModules.software-swaybg
        inputs.self.nixosModules.fonts-jetbrains
        inputs.self.nixosModules.fonts-firacode
      ];

      # System packages available globally
      environment.systemPackages = with pkgs; [
        brightnessctl
        fzf
        grim
        gum
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
