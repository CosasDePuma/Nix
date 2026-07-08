{
  inputs,
  lib,
  ...
}: {
  flake = {
    homeManagerModules.rice-retro = {pkgs, ...}: {
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

      home.pointerCursor = lib.mkForce {
        package = pkgs.hackneyed;
        name = "Hackneyed";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      wayland.windowManager.hyprland = {
        configType = "lua";
        settings = {
          exec-once = lib.mkForce [
            "${pkgs.networkmanagerapplet}/bin/nm-applet"
            "${pkgs.swaybg}/bin/swaybg -i ${./.wallpapers/peak_into_the_system.png} -m fill"
            "hyprctl dispatch exec quickshell"
            "${pkgs.systemd}/bin/systemctl --user start hyprpolkitagent"
            "${pkgs.hyprland}/bin/hyprctl setcursor Hackneyed 24"
          ];

          env = lib.mkDefault [
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
          ];

          animations = lib.mkForce {
            enabled = false;
          };

          general = lib.mkForce {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 1;
            "col.active_border" = "rgb(d8d8d8)";
            "col.inactive_border" = "rgb(9b9b9b)";
            resize_on_border = true;
            layout = "dwindle";
            allow_tearing = false;
          };

          decoration = lib.mkForce {
            rounding = 0;
            active_opacity = 1.0;
            inactive_opacity = 1.0;
            shadow = {
              enabled = true;
              range = 2;
              render_power = 5;
              sharp = false;
              color = "rgba(0,0,0,0.85)";
              offset = "2 2";
              scale = 1.0;
            };
            blur = {
              enabled = false;
            };
          };

          bind = lib.mkDefault [
            "SUPER SHIFT, S, exec, ${pkgs.hyprshot}/bin/hyprshot --mode region --output-folder /tmp"
            "SUPER, E, exec, ${pkgs.nemo}/bin/nemo"
            "SUPER, Space, exec, ${pkgs.quickshell}/bin/quickshell ipc call appLauncher_$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == true) | .name') toggleAppLauncher"
          ];
        };
      };

      programs.kitty = {
        enable = true;
        extraConfig = lib.mkForce (builtins.readFile ./.kitty/default_theme.conf);
      };

      xdg.configFile."quickshell".source = lib.mkForce ./.quickshell;
      xdg.dataFile."icons/RetroismIcons".source = ./.icons/RetroismIcons;
    };

    nixosModules.rice-retro = {
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
