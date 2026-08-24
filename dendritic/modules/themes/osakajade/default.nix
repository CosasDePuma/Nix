_: let
  colors = builtins.fromTOML (builtins.readFile ./colors.toml);
  wallpaper = ./backgrounds/1-glowing-city.webp;
in {
  flake.homeManagerModules.themes-osakajade = {
    config,
    lib,
    pkgs,
    ...
  }:
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
