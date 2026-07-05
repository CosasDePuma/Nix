{inputs, ...}: {
  flake = {
    homeManagerModules.rice-antiquity = {pkgs, ...}: {
      imports = [
        inputs.self.homeManagerModules.software-hyprland
        inputs.self.homeManagerModules.software-quickshell
        inputs.self.homeManagerModules.software-mako
        inputs.self.homeManagerModules.software-jq
        inputs.self.homeManagerModules.software-socat
      ];

      home.packages = with pkgs; [
        nemo
        nwg-look
      ];

      wayland.windowManager.hyprland = {
        settings = {
          monitor = [
            ",preferred,auto,1"
          ];

          exec-once = [
            "nm-applet"
            "hyprpaper"
            "qs"
            "systemctl --user start hyprpolkitagent"
            "hyprctl setcursor Hackneyed-24px 24"
          ];

          env = [
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
          ];

          input = {
            kb_layout = "us,se";
            kb_options = "grp:alt_shift_toggle";
            follow_mouse = 1;
            sensitivity = 0;
            touchpad = {
              natural_scroll = false;
            };
          };

          cursor = {
            no_hardware_cursors = true;
          };

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

          dwindle = {
            preserve_split = true;
          };

          master = {
            new_status = "master";
          };

          misc = {
            force_default_wallpaper = 0;
            disable_hyprland_logo = true;
          };

          bind = [
            "SUPER, Return, exec, kitty"
            "SUPER, Q, killactive,"
            "SUPER SHIFT, S, exec, hyprshot --mode region --output-folder /tmp"
            "SUPER, E, exec, nemo"
            "SUPER SHIFT, SPACE, togglefloating,"
            "SUPER, F, fullscreen,"
            "SUPER, D, exec, quickshell ipc call appLauncher_$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name') toggleAppLauncher"
            "SUPER, 1, workspace, 1"
            "SUPER SHIFT, 1, movetoworkspace, 1"
            "SUPER, 2, workspace, 2"
            "SUPER SHIFT, 2, movetoworkspace, 2"
            "SUPER, 3, workspace, 3"
            "SUPER SHIFT, 3, movetoworkspace, 3"
            "SUPER, 4, workspace, 4"
            "SUPER SHIFT, 4, movetoworkspace, 4"
            "SUPER, 5, workspace, 5"
            "SUPER SHIFT, 5, movetoworkspace, 5"
            "SUPER, 6, workspace, 6"
            "SUPER SHIFT, 6, movetoworkspace, 6"
            "SUPER, 7, workspace, 7"
            "SUPER SHIFT, 7, movetoworkspace, 7"
            "SUPER, 8, workspace, 8"
            "SUPER SHIFT, 8, movetoworkspace, 8"
            "SUPER, 9, workspace, 9"
            "SUPER SHIFT, 9, movetoworkspace, 9"
            "SUPER, 0, workspace, 10"
            "SUPER SHIFT, 0, movetoworkspace, 10"
          ];

          binde = [
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
            ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
          ];

          bindm = [
            "SUPER, mouse:272, movewindow"
            "SUPER, mouse:273, resizewindow"
          ];
        };

        extraConfig = ''
          layerrule = blur 1, match:namespace diinki_celestialantiquity:bars
          layerrule = ignore_alpha 0.19, match:namespace diinki_celestialantiquity:bars
          layerrule = blur 1, match:namespace diinki_celestialantiquity:no_blur
          layerrule = ignore_alpha 0.19, match:namespace diinki_celestialantiquity:no_blur
        '';
      };

      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          preload = [
            "${inputs.linux-antiquity}/configs/hypr/wallpapers_bundled/georges_riom_collage.png"
          ];
          wallpaper = [
            ",${inputs.linux-antiquity}/configs/hypr/wallpapers_bundled/georges_riom_collage.png"
          ];
        };
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
        extraConfig = builtins.readFile "${inputs.linux-antiquity}/configs/kitty/hades.conf";
      };

      xdg.configFile."quickshell".source = "${inputs.linux-antiquity}/configs/quickshell";
      xdg.dataFile."icons/buuf-nestort".source = "${inputs.linux-antiquity}/iconTheme/buuf-nestort";
    };

    nixosModules.rice-antiquity = {
      imports = [
        inputs.self.nixosModules.software-hyprland
        inputs.self.nixosModules.software-quickshell
        inputs.self.nixosModules.software-mako
        inputs.self.nixosModules.software-jq
        inputs.self.nixosModules.software-socat
      ];
    };
  };
}
