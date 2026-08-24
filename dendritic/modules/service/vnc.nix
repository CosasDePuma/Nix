_: {
  flake.nixosModules.service-vnc = {lib, ...}: {
    # Same gnome-remote-desktop daemon as the RDP option, just in VNC mode
    # instead: it works over the standard desktop-portal RemoteDesktop/
    # ScreenCast interfaces, not GNOME Shell's own built-in remote desktop,
    # so it's compositor-agnostic (Hyprland here via
    # xdg-desktop-portal-hyprland, but not tied to it) rather than a
    # wlroots-specific tool like wayvnc. VNC uses port 5900 by default,
    # separate from the 3389 windows-vm forwards its container's RDP to.
    services.gnome.gnome-remote-desktop.enable = lib.mkDefault true;

    # Multi-owner/additive: other services may open other ports here too.
    networking.firewall.allowedTCPPorts = [5900];
  };
}
