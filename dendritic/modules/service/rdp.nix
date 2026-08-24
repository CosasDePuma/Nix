_: {
  flake.nixosModules.service-rdp = {lib, ...}: {
    # System daemon for remote login (grdctl --system): connecting starts a
    # fresh session, independent of whatever's on the physical monitor --
    # not screen-sharing an already-running desktop.
    services.gnome.gnome-remote-desktop.enable = lib.mkDefault true;

    # grdctl's own `rdp enable` also tries to `systemctl enable` the unit,
    # which fails against NixOS's read-only /etc/systemd/system. Enabling
    # it declaratively here means grdctl never has to, so the one-time
    # setup below doesn't hit that error.
    systemd.services.gnome-remote-desktop.wantedBy = ["graphical.target"];

    # Multi-owner/additive: other services may open other ports here too.
    networking.firewall.allowedTCPPorts = [3389];

    # Credentials aren't set here -- run once per host, as any user in
    # wheel (root bypasses the polkit prompt outright):
    #   sudo grdctl --system rdp set-credentials <user> <password>
    #   sudo grdctl --system rdp enable
  };
}
