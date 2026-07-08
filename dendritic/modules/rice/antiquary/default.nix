{
  inputs,
  lib,
  ...
}: {
  flake = {
    homeManagerModules.rice-antiquary = {pkgs, ...}: {
      imports = [
        inputs.self.homeManagerModules.software-quickshell
        inputs.self.homeManagerModules.software-mako
        inputs.self.homeManagerModules.software-jq
        inputs.self.homeManagerModules.software-socat
        inputs.self.homeManagerModules.software-nemo
        inputs.self.homeManagerModules.software-swaybg
        inputs.self.homeManagerModules.software-nwg-look
        inputs.self.homeManagerModules.software-hyprshot
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
            "quickshell"
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
            "SUPER, Space, exec, ${pkgs.quickshell}/bin/quickshell ipc call appLauncher_$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == true) | .name') toggleAppLauncher"
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
        extraConfig = builtins.readFile ./.kitty/hades.conf;
      };

      xdg.configFile."quickshell".source = ./.quickshell;
      xdg.dataFile."icons/buuf-nestort".source = ./.icons/buuf-nestort;
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
      ];
    };
  };
}
