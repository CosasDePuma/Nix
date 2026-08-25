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
      # Thin wrappers over the vendored shell's plugin IPC surface, mirroring
      # upstream bin/omarchy-menu and bin/omarchy-menu-clipboard. They call
      # omarchy-shell by bare name because its wrapper derivation lives in
      # software-omarchy-shell (imported below), which puts it on PATH; there
      # is no pkgs attribute to interpolate a store path from.
      omarchy-menu = pkgs.writeShellApplication {
        name = "omarchy-menu";
        runtimeInputs = [pkgs.jq];
        text = ''
          verb="''${1:-toggle}"
          route="''${2:-root}"

          menu_payload() {
            jq -nc --arg menu "$1" '{ menu: $menu }'
          }

          case "$verb" in
            toggle)
              exec omarchy-shell shell toggle omarchy.menu "$(menu_payload "$route")"
              ;;
            summon)
              exec omarchy-shell shell summon omarchy.menu "$(menu_payload "$route")"
              ;;
            close)
              exec omarchy-shell shell hide omarchy.menu
              ;;
            refresh | ping)
              exec omarchy-shell shell call omarchy.menu "$verb" "{}"
              ;;
            *)
              echo "Usage: omarchy-menu [toggle|summon|close|refresh|ping] [route]" >&2
              exit 1
              ;;
          esac
        '';
      };

      omarchy-menu-clipboard = pkgs.writeShellApplication {
        name = "omarchy-menu-clipboard";
        text = ''
          exec omarchy-shell shell toggle omarchy.clipboard
        '';
      };

      omarchy-system-lock = pkgs.writeShellApplication {
        name = "omarchy-system-lock";
        # omarchy-shell resolves from PATH: its wrapper derivation lives in
        # software-omarchy-shell (imported below), and hyprctl in the session
        # environment provided by software-hyprland.
        text = ''
          omarchy-shell lock lock >/dev/null
          # Reset keyboard layout to the default one, best effort (upstream
          # parity).
          hyprctl switchxkblayout all 0 >/dev/null 2>&1 || true
        '';
      };

      # Port of upstream bin/omarchy-audio-output-sink: the shell's audio
      # panel polls it (every 15s) to resolve which physical sink really
      # carries volume when a DSP sink fronts it. Needs pactl and awk.
      omarchy-audio-output-sink = pkgs.writeShellApplication {
        name = "omarchy-audio-output-sink";
        runtimeInputs = [pkgs.pulseaudio pkgs.gawk];
        text = ''
          sink="''${1:-$(pactl get-default-sink 2>/dev/null)}"

          if [[ -z $sink || $sink == alsa_output.* ]]; then
            printf '%s\n' "$sink"
            exit 0
          fi

          # A DSP sink feeds its physical output through a stream of its own;
          # follow that stream down to the sink underneath.
          downstream="$(pactl list sink-inputs 2>/dev/null |
            awk -v virt="$sink" '
              /^Sink Input #/ {target = ""}
              /^[[:space:]]*Sink:/ {target = $2}
              /node\.name = / {
                name = $0
                sub(/.*node\.name = "/, "", name)
                sub(/"$/, "", name)
                if (index(name, virt) == 1 && target != "") {print target; exit}
              }
              /application\.name = "EasyEffects"/ {
                if (virt == "easyeffects_sink" && target != "") {print target; exit}
              }')"

          if [[ -n $downstream ]]; then
            name="$(pactl list sinks short 2>/dev/null |
              awk -v id="$downstream" '$1 == id {print $2; exit}')"
            if [[ -n $name ]]; then
              printf '%s\n' "$name"
              exit 0
            fi
          fi

          # Nothing resolvable downstream -- the DSP sink may simply be idle.
          # Fall back to the sink itself so callers still have something to
          # act on.
          printf '%s\n' "$sink"
        '';
      };

      omarchy-theme-switcher = pkgs.writeShellApplication {
        name = "omarchy-theme-switcher";
        runtimeInputs = [pkgs.coreutils pkgs.fuzzel pkgs.libnotify pkgs.procps pkgs.swaybg];
        text = ''
          theme_dir="$HOME/.config/omarchy/themes"
          if [ ! -d "$theme_dir" ]; then
            notify-send "Omarchy" "No themes installed yet"
            exit 0
          fi
          theme=$(find "$theme_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | fuzzel --dmenu --prompt "🎨 ") || exit 0
          wallpaper=$(find "$theme_dir/$theme" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | head -n 1)
          if [ -n "$wallpaper" ]; then
            pkill -x swaybg 2>/dev/null || true
            nohup swaybg -i "$wallpaper" -m fill >/dev/null 2>&1 &
          fi
          printf '%s\n' "$theme" > "$HOME/.config/omarchy/current-theme"
          notify-send "Omarchy" "Theme: $theme"
        '';
      };
    in {
      imports = [
        inputs.self.homeManagerModules.fonts-jetbrains
        inputs.self.homeManagerModules.settings-gtk
        inputs.self.homeManagerModules.software-hyprland
        inputs.self.homeManagerModules.software-mako
        inputs.self.homeManagerModules.software-omarchy-shell
        inputs.self.homeManagerModules.software-quickshell
        inputs.self.homeManagerModules.settings-wayland
        inputs.self.homeManagerModules.software-warp
        inputs.self.homeManagerModules.software-starship
        inputs.self.homeManagerModules.software-swaybg
      ];

      # Environment variables for Omarchy desktop ecosystem. OMARCHY_PATH
      # itself is owned by software-omarchy-shell (it points at the
      # vendored shell app, not this ~/.config/omarchy config dir).
      home.sessionVariables = {
        TERMINAL = lib.mkDefault "warp-terminal";
        XDG_CURRENT_DESKTOP = lib.mkDefault "Hyprland";
        XDG_SESSION_DESKTOP = lib.mkDefault "Hyprland";
      };

      # omarchy-theme-switcher shells out to the bare fuzzel binary, but it
      # still reads ~/.config/fuzzel/fuzzel.ini, so managing it here themes
      # every launcher invocation for free.
      programs.fuzzel.enable = lib.mkDefault true;

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

      # Hyprland custom configuration in Omarchy style
      wayland.windowManager.hyprland = {
        enable = lib.mkDefault true;
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
            {_args = ["SUPER + RETURN" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${pkgs.warp-terminal}/bin/warp-terminal")'')];}
            {_args = ["SUPER + SPACE" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${omarchy-menu}/bin/omarchy-menu")'')];}
            {_args = ["SUPER + V" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${omarchy-menu-clipboard}/bin/omarchy-menu-clipboard")'')];}
            {_args = ["SUPER + COMMA" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${omarchy-theme-switcher}/bin/omarchy-theme-switcher")'')];}
            {_args = ["SUPER + ESCAPE" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${omarchy-system-lock}/bin/omarchy-system-lock")'')];}

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
          omarchy-theme-switcher
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
          ExecStart = "${config.services.mako.package}/bin/mako";
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
        inputs.self.nixosModules.software-warp
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
