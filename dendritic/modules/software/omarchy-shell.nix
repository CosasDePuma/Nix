_: let
  vendor = ./omarchy-shell/vendor;
in {
  flake.homeManagerModules.software-omarchy-shell = {
    lib,
    pkgs,
    ...
  }: let
    omarchy-shell = pkgs.writeShellApplication {
      name = "omarchy-shell";
      runtimeInputs = [pkgs.quickshell];
      text = ''
        # Matches upstream's own launcher: the store path is read-only and
        # immutable, so there is nothing for Quickshell's file watcher to
        # usefully watch, and no in-place reload to warn about.
        export QS_DISABLE_FILE_WATCHER=1
        export QS_NO_RELOAD_POPUP=1
        exec quickshell -n -p "$OMARCHY_PATH/shell"
      '';
    };
  in {
    # The single source of truth for where the vendored shell app + its
    # bundled defaults live. Points at the Nix store, not ~/.config/omarchy
    # (that's per-user state -- shell.json overrides, themes -- a distinct
    # concept upstream keeps separate too).
    home.sessionVariables.OMARCHY_PATH = lib.mkDefault "${vendor}";

    home.packages = [omarchy-shell];

    systemd.user.services.omarchy-shell = {
      Unit = {
        Description = "Omarchy Quickshell bar";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        # uwsm imports WAYLAND_DISPLAY into the systemd user manager after
        # activating the target, so the first start(s) can race it. Widen
        # the burst window instead of failing permanently.
        StartLimitIntervalSec = 60;
        StartLimitBurst = 10;
      };
      Service = {
        ExecStart = "${omarchy-shell}/bin/omarchy-shell";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
