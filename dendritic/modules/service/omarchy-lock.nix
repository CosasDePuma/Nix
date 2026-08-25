_: {
  flake.nixosModules.service-omarchy-lock = {
    config,
    lib,
    ...
  }: {
    # The Quickshell lock screen authenticates against these PAM service
    # names (see omarchy-shell vendor shell/plugins/lock/Service.qml), so a
    # security.pam.services.hyprlock entry does nothing for it. NixOS
    # structured defaults provide pam_unix password auth; upstream
    # additionally arms faillock (deny=10 / unlock_time=120, see upstream
    # bin/omarchy-apply-lock), which hosts can enable globally through
    # security.pam.faillock.
    security.pam.services.omarchy-lock-password = lib.mkDefault {};

    # Upstream only writes this stack when fprintd reports enrolled fingers;
    # deriving the same condition from services.fprintd.enable keeps hosts
    # without a reader free of a dangling PAM config.
    security.pam.services.omarchy-lock-fingerprint = lib.mkIf config.services.fprintd.enable (lib.mkDefault {
      text = ''
        auth       required       pam_fprintd.so
      '';
    });
  };
}
