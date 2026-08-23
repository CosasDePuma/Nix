{
  inputs,
  lib,
  ...
}: {
  flake = {
    homeManagerModules.software-hyprland = {
      config,
      lib,
      pkgs,
      osConfig ? {},
      ...
    }: {
      imports = [inputs.self.homeManagerModules.settings-wayland];
      config = lib.mkMerge [
        {
          wayland.windowManager.hyprland = {
            enable = lib.mkDefault true;
            configType = lib.mkDefault "lua";
            # uwsm owns graphical-session.target when managing the session;
            # this integration stop/starts a bound target mid-startup and tears
            # the uwsm envelope down with it.
            systemd.enable = lib.mkDefault false;
            settings = {
              config = {
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
              };

              env = lib.mkDefault [
                {_args = ["XDG_CURRENT_DESKTOP" "Hyprland"];}
                {_args = ["XDG_SESSION_DESKTOP" "Hyprland"];}
              ];

              bind = [
                {_args = ["SUPER + RETURN" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.kitty}/bin/kitty")'')];}
                {_args = ["SUPER + Q" (lib.generators.mkLuaInline "hl.dsp.window.close()")];}
                {_args = ["SUPER + SHIFT + SPACE" (lib.generators.mkLuaInline ''hl.dsp.window.float({action = "toggle"})'')];}
                {_args = ["SUPER + F" (lib.generators.mkLuaInline "hl.dsp.window.fullscreen()")];}
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
                {_args = ["XF86AudioRaiseVolume" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")'') {repeating = true;}];}
                {_args = ["XF86AudioLowerVolume" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'') {repeating = true;}];}
                {_args = ["XF86AudioMute" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')];}
                {_args = ["XF86AudioMicMute" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'')];}
                {_args = ["XF86MonBrightnessUp" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl s 10%+")'') {repeating = true;}];}
                {_args = ["XF86MonBrightnessDown" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl s 10%-")'') {repeating = true;}];}
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
        }

        # Auto-launch the compositor session from a free VT. Through uwsm when
        # the system module provides it (degrading to the direct launcher if
        # uwsm fails), or straight to the launcher otherwise.
        (lib.mkIf (config.programs.zsh.enable or false) (
          if (osConfig.programs.uwsm.enable or false)
          then {
            programs.zsh.loginExtra = lib.mkDefault ''
              if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
                ${pkgs.uwsm}/bin/uwsm start -D Hyprland || exec ${config.wayland.windowManager.hyprland.finalPackage}/bin/start-hyprland
              fi
            '';
          }
          else {
            programs.zsh.loginExtra = lib.mkDefault ''
              if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
                exec ${config.wayland.windowManager.hyprland.finalPackage}/bin/start-hyprland
              fi
            '';
          }
        ))
      ];
    };

    nixosModules.software-hyprland = {pkgs, ...}: {
      imports = [
        inputs.self.nixosModules.settings-wayland
        inputs.self.nixosModules.software-uwsm
      ];
      programs.hyprland = {
        enable = lib.mkDefault true;
        withUWSM = lib.mkDefault true;
        xwayland.enable = lib.mkDefault true;
        portalPackage = lib.mkDefault pkgs.xdg-desktop-portal-hyprland;
      };
    };
  };
}
