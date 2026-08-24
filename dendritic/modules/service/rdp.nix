_: {
  flake.nixosModules.service-rdp = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Desktop-oriented module: derive the account to configure RDP
    # credentials for from the system instead of hardcoding a username.
    normalUsers =
      lib.attrNames
      (lib.filterAttrs (_: user: user.isNormalUser or false) config.users.users);
    primaryUser = lib.head (normalUsers ++ [null]);
  in {
    # System-level secret: decrypted at NixOS activation using the host's
    # own SSH host key (age.identityPaths defaults to it once openssh is
    # enabled), not a personal identity -- there's no user session yet at
    # boot to hold one.
    age.secrets.rdp-password = lib.mkIf (primaryUser != null) {
      file = ./rdp.age;
      mode = "0400";
    };

    # System daemon for remote login (grdctl --system): connecting starts a
    # fresh session, independent of whatever's on the physical monitor --
    # not screen-sharing the already-running desktop (that's the separate
    # --headless/per-user mode, which Hyprland doesn't autostart the way
    # GNOME Shell does).
    services.gnome.gnome-remote-desktop.enable = lib.mkDefault true;

    # grdctl's own `rdp enable` also tries to `systemctl enable` the unit,
    # which fails against NixOS's read-only /etc/systemd/system. Enabling
    # it declaratively here means grdctl never has to.
    systemd.services.gnome-remote-desktop.wantedBy = ["graphical.target"];

    # grdctl persists its config to a local keyfile (no TPM available, so
    # it falls back there instead of a hardware-backed keyring), which is
    # why re-running this on every activation is idempotent rather than
    # prompting. Root bypasses the org.gnome.remotedesktop.
    # configure-system-daemon polkit action outright (verified: `sudo
    # grdctl --system ...` needs no polkit prompt), so no polkit rule is
    # needed either -- this just has to run as root, which a NixOS
    # systemd.services unit does by default.
    systemd.services.gnome-remote-desktop-configure = lib.mkIf (primaryUser != null) {
      description = "Configure gnome-remote-desktop RDP port and credentials";
      before = ["gnome-remote-desktop.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      # grdctl --system shells out to pkexec internally even when the
      # caller is already root; without this it's not on the unit's PATH.
      path = [pkgs.polkit];
      script = ''
        ${pkgs.gnome-remote-desktop}/bin/grdctl --system rdp set-port 3390
        ${pkgs.gnome-remote-desktop}/bin/grdctl --system rdp set-credentials \
          ${lib.escapeShellArg primaryUser} "$(cat ${config.age.secrets.rdp-password.path})"
        ${pkgs.gnome-remote-desktop}/bin/grdctl --system rdp enable
      '';
    };

    # Multi-owner/additive: other services may open other ports here too.
    # 3390, not RDP's default 3389 -- windows-vm forwards its container's
    # RDP to 127.0.0.1:3389, and this binds every interface (including
    # loopback), so the two would collide if both were ever wanted at once.
    networking.firewall.allowedTCPPorts = [3390];
  };
}
