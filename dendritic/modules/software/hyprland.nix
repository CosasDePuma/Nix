{
  inputs,
  lib,
  ...
}: {
  flake = {
    homeManagerModules.software-hyprland = _: {
      imports = [inputs.self.homeManagerModules.settings-wayland];
      wayland.windowManager.hyprland = {
        enable = lib.mkDefault true;
        settings = {
          monitor = lib.mkDefault [
            ",preferred,auto,1"
          ];

          env = lib.mkDefault [
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_DESKTOP,Hyprland"
          ];

          input = {
            kb_layout = lib.mkDefault "us,se";
            kb_options = lib.mkDefault "grp:alt_shift_toggle";
            follow_mouse = lib.mkDefault 1;
            sensitivity = lib.mkDefault 0;
            touchpad = {
              natural_scroll = lib.mkDefault false;
            };
          };

          cursor = {
            no_hardware_cursors = lib.mkDefault true;
          };

          dwindle = {
            preserve_split = lib.mkDefault true;
          };

          master = {
            new_status = lib.mkDefault "master";
          };

          misc = {
            force_default_wallpaper = lib.mkDefault 0;
            disable_hyprland_logo = lib.mkDefault true;
          };

          bind = lib.mkDefault [
            "SUPER, Return, exec, kitty"
            "SUPER, Q, killactive,"
            "SUPER, S, togglefloating,"
            "SUPER, F, fullscreen,"
            "SUPER, Left, movefocus, l"
            "SUPER, Right, movefocus, r"
            "SUPER, Up, movefocus, u"
            "SUPER, Down, movefocus, d"
            "SUPER SHIFT, Left, workspace, e-1"
            "SUPER SHIFT, Right, workspace, e+1"
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

          windowrulev2 = lib.mkDefault [
            "float, class:^(kitty)$"
            "center, class:^(kitty)$"
            "size 800 500, class:^(kitty)$"
          ];

          binde = lib.mkDefault [
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
            ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
          ];

          bindm = lib.mkDefault [
            "SUPER, mouse:272, movewindow"
            "SUPER, mouse:273, resizewindow"
          ];
        };
      };
    };

    nixosModules.software-hyprland = {pkgs, ...}: {
      imports = [inputs.self.nixosModules.settings-wayland];
      programs = {
        dconf.enable = lib.mkDefault true;
        hyprland.enable = lib.mkDefault true;
      };
      services.dbus.enable = lib.mkDefault true;
      xdg.portal = {
        enable = lib.mkDefault true;
        extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
        config.common.default = lib.mkDefault ["hyprland"];
        xdgOpenUsePortal = lib.mkDefault true;
      };
    };
  };
}
