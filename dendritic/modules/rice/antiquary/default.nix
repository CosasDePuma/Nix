{
  inputs,
  lib,
  ...
}: {
  flake = {
    homeManagerModules.rice-antiquary = {
      pkgs,
      config,
      ...
    }: {
      imports = [
        inputs.self.homeManagerModules.software-quickshell
        inputs.self.homeManagerModules.software-mako
        inputs.self.homeManagerModules.software-jq
        inputs.self.homeManagerModules.software-socat
        inputs.self.homeManagerModules.software-nemo
        inputs.self.homeManagerModules.software-swaybg
        inputs.self.homeManagerModules.software-nwg-look
        inputs.self.homeManagerModules.software-hyprshot
        inputs.self.homeManagerModules.software-rofi
      ];

      home.pointerCursor = {
        package = pkgs.hackneyed;
        name = "Hackneyed";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      wayland.windowManager.hyprland = {
        configType = "hyprlang";
        settings = {
          exec-once = lib.mkDefault [
            "${pkgs.networkmanagerapplet}/bin/nm-applet"
            "${pkgs.swaybg}/bin/swaybg -i ${./.wallpapers/georges_riom.png} -m fill"
            "hyprctl dispatch exec quickshell"
            "${pkgs.systemd}/bin/systemctl --user start hyprpolkitagent"
            "${pkgs.hyprland}/bin/hyprctl setcursor Hackneyed 24"
          ];

          env = lib.mkDefault [
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
          ];

          animations = {
            enabled = true;
            bezier = "smooth, 0.22, 1, 0.36, 1";
            animation = [
              "workspaces, 1, 8, smooth, slide"
              "windows, 1, 3, smooth"
              "fade, 1, 3, smooth"
            ];
          };

          general = {
            gaps_in = 4;
            gaps_out = 8;
            border_size = 1;
            "col.active_border" = "rgb(1c1c1c)";
            "col.inactive_border" = "rgb(1c1c1c)";
            resize_on_border = false;
            layout = "dwindle";
            allow_tearing = false;
          };

          decoration = {
            rounding = 9;
            rounding_power = 4;
            active_opacity = 1.0;
            inactive_opacity = 1.0;
            shadow = {
              enabled = true;
              range = 12;
              render_power = 6;
              sharp = false;
              color = "rgba(0,0,0,0.19)";
              offset = "0, 0";
              scale = 1.0;
            };
            blur = {
              enabled = true;
              size = 3;
              passes = 2;
              noise = 0.023;
              contrast = 0.9;
              new_optimizations = true;
            };
          };

          bind = lib.mkDefault [
            "SUPER SHIFT, S, exec, ${pkgs.hyprshot}/bin/hyprshot --mode region --output-folder /tmp"
            "SUPER, E, exec, ${pkgs.nemo}/bin/nemo"
            "SUPER, Space, exec, ${pkgs.rofi}/bin/rofi -show drun"
          ];
        };

        extraConfig = ''
          layerrule = blur on, match:namespace diinki_celestialantiquity:bars
          layerrule = ignore_alpha 0.19, match:namespace diinki_celestialantiquity:bars
          layerrule = blur on, match:namespace diinki_celestialantiquity:no_blur
          layerrule = ignore_alpha 0.19, match:namespace diinki_celestialantiquity:no_blur
        '';
      };

      programs.kitty = {
        enable = true;
        font = {
          name = "maple mono";
          size = 11;
        };
        settings = {
          font_weight = "800";
        };
        extraConfig = builtins.readFile ./.kitty/gruvbox.conf;
      };

      xdg.configFile."quickshell".source = ./.quickshell;

      programs.rofi = {
        extraConfig = {
          show-icons = true;
          icon-theme = "buuf-nestort";
        };
        theme = let
          inherit (config.lib.formats.rasi) mkLiteral;
          rofi-bg = pkgs.runCommand "rofi-bg.svg" {} ''
            sed 's/#000000/#87704f/g' ${./.quickshell/assets/background_pattern_mono_1.svg} > $out
          '';
        in {
          "*" = {
            bg = mkLiteral "#fce2ab33";
            bg-input = mkLiteral "#181818";
            fg = mkLiteral "#121212";
            fg-alt = mkLiteral "#d0daed";
            fg-accent = mkLiteral "#fccf8a";
            border-col = mkLiteral "#121212";
            border-element = mkLiteral "#333333";

            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@fg";
            font = "Quilon 15";
          };
          "window" = {
            background-color = mkLiteral "@bg";
            border = mkLiteral "1px";
            border-color = mkLiteral "@border-col";
            border-radius = mkLiteral "12px";
            padding = mkLiteral "10px";
            width = mkLiteral "600px";
          };
          "mainbox" = {
            children = mkLiteral "[inputbar, listview]";
            spacing = mkLiteral "8px";
          };
          "inputbar" = {
            children = mkLiteral "[prompt, entry]";
            background-color = mkLiteral "@bg-input";
            background-image = mkLiteral ''url("${rofi-bg}", width)'';
            border-radius = mkLiteral "6px";
            padding = mkLiteral "10px";
          };
          "prompt" = {
            text-color = mkLiteral "@fg-accent";
            padding = mkLiteral "0 10px 0 0";
            font = "Recia Bold 17";
          };
          "entry" = {
            text-color = mkLiteral "@fg-accent";
            placeholder = "Search apps...";
            placeholder-color = mkLiteral "#87704f";
            font = "Recia Bold 17";
            horizontal-align = mkLiteral "0.5";
          };
          "listview" = {
            lines = 6;
            spacing = mkLiteral "9px";
            background-color = mkLiteral "@bg-input";
            background-image = mkLiteral ''url("${rofi-bg}", width)'';
            border-radius = mkLiteral "6px";
            padding = mkLiteral "8px";
          };
          "element" = {
            padding = mkLiteral "6px 8px";
            border-radius = mkLiteral "4px";
            background-color = mkLiteral "@bg-input";
            border = mkLiteral "1px";
            border-color = mkLiteral "@border-element";
          };
          "element selected" = {
            border-color = mkLiteral "@fg-accent";
          };
          "element-text" = {
            vertical-align = mkLiteral "0.5";
            text-color = mkLiteral "@fg-alt";
          };
          "element-text selected" = {
            text-color = mkLiteral "@fg-accent";
          };
          "element-icon" = {
            size = mkLiteral "38px";
            padding = mkLiteral "0 12px 0 0";
          };
        };
      };
    };

    nixosModules.rice-antiquary = {
      imports = [
        inputs.self.nixosModules.software-quickshell
        inputs.self.nixosModules.software-mako
        inputs.self.nixosModules.software-jq
        inputs.self.nixosModules.software-socat
        inputs.self.nixosModules.software-nemo
        inputs.self.nixosModules.software-swaybg
        inputs.self.nixosModules.software-nwg-look
        inputs.self.nixosModules.software-hyprshot
        inputs.self.nixosModules.software-rofi
      ];
    };
  };
}
