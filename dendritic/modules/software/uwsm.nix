_: {
  flake.nixosModules.software-uwsm = {
    config,
    lib,
    ...
  }: {
    programs.uwsm.enable = lib.mkDefault true;

    # Compositors registered with uwsm ship two session entries: their own
    # direct launcher and the uwsm-managed one. Prune the direct launchers so
    # every session goes through the uwsm envelope.
    environment.extraSetup = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: _: ''rm -f "$out/share/wayland-sessions/${name}.desktop"''
      )
      (config.programs.uwsm.waylandCompositors or {})
    );
  };
}
