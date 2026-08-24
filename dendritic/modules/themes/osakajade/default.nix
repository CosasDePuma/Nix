_: let
  colors = builtins.fromTOML (builtins.readFile ./colors.toml);
  wallpaper = ./backgrounds/1-glowing-city.webp;
in {
  flake.homeManagerModules.themes-osakajade = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # fuzzel.ini wants bare RRGGBBAA, no leading #.
    hex = c: lib.removePrefix "#" c;
  in
    # --- hyprland
    lib.mkIf (config.wayland.windowManager.hyprland.enable or false) {
      wayland.windowManager.hyprland.settings.config.general = {
        "col.active_border" = lib.mkDefault (
          lib.generators.mkLuaInline ''{colors = {"${colors.accent}ee", "${colors.dark_foreground}ee"}, angle = 45}''
        );
        "col.inactive_border" = lib.mkDefault "${colors.selection}aa";
      };

      # --- mako
      services.mako.settings = {
        background-color = "${colors.dark_background}ee";
        text-color = colors.foreground;
        border-color = colors.accent;
        border-size = 2;
        border-radius = 10;
        progress-color = "over ${colors.dark_foreground}";
      };

      # --- fuzzel (SUPER + SPACE launcher, also used by the clipboard and
      # theme-switcher menus)
      programs.fuzzel.settings = {
        colors = {
          background = "${hex colors.dark_background}ee";
          text = hex colors.foreground;
          prompt = hex colors.accent;
          placeholder = hex colors.muted;
          input = hex colors.foreground;
          match = hex colors.dark_foreground;
          selection = "${hex colors.selection}cc";
          selection-text = hex colors.bright_foreground;
          selection-match = hex colors.accent;
          border = hex colors.accent;
        };
        border = {
          width = 2;
          radius = 10;
        };
      };

      # --- wallpaper
      systemd.user.services.wallpaper = {
        Unit = {
          Description = "Wallpaper";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          StartLimitIntervalSec = 60;
          StartLimitBurst = 10;
        };
        Service = {
          ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill";
          Restart = "on-failure";
          RestartSec = "2s";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
}
