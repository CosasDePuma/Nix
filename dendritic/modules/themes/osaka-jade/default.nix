_: let
  colors = builtins.fromTOML (builtins.readFile ./colors.toml);
  wallpaper = ./backgrounds/1-glowing-city.webp;
in {
  flake.homeManagerModules.themes-osaka-jade = {
    config,
    lib,
    pkgs,
    ...
  }:
    lib.mkIf (config.wayland.windowManager.hyprland.enable or false) {
      wayland.windowManager.hyprland.settings.config.general = {
        "col.active_border" = lib.mkDefault (
          lib.generators.mkLuaInline ''{colors = {"${colors.accent}ee", "${colors.dark_foreground}ee"}, angle = 45}''
        );
        "col.inactive_border" = lib.mkDefault "${colors.selection}aa";
      };

      systemd.user.services.themes-osaka-jade-wallpaper = {
        Unit = {
          Description = "Osaka Jade wallpaper";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          # uwsm imports WAYLAND_DISPLAY into the systemd user manager after
          # activating the target, so the first start(s) can race it. Widen
          # the burst window instead of failing permanently.
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
