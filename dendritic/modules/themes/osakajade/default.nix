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
      # Mirrors omarchy's own shell.toml [notifications] tokens (background,
      # foreground, accent border/countdown) so a notify-send toast looks
      # like it belongs, even though upstream now renders these itself
      # through Quickshell instead of mako.
      services.mako.settings = {
        background-color = "${hex colors.background}ff";
        text-color = hex colors.foreground;
        border-color = hex colors.accent;
        border-size = 2;
        border-radius = 10;
        progress-color = "over ${hex colors.accent}";
      };

      # --- fuzzel (SUPER + SPACE launcher, also used by the clipboard and
      # theme-switcher menus). Mirrors omarchy's shell.toml [launcher]
      # tokens: background/text/border follow the same background,
      # foreground, and hyprland-active-border-foreground (-> foreground,
      # no override set) roles upstream uses for its own launcher overlay.
      programs.fuzzel.settings = {
        colors = {
          background = "${hex colors.background}f2"; # alpha 0.95, like upstream
          text = hex colors.foreground;
          prompt = hex colors.accent;
          placeholder = hex colors.muted;
          input = hex colors.foreground;
          match = hex colors.accent;
          selection = "${hex colors.foreground}14"; # alpha 0.08, like upstream
          selection-text = hex colors.accent;
          selection-match = hex colors.bright_foreground;
          border = hex colors.foreground;
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
