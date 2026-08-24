_: {
  flake.nixosModules.service-rdp = {lib, ...}: {
    # Headless RDP via PipeWire + the portal's RemoteDesktop/ScreenCast
    # interfaces, not GNOME Shell's own built-in remote desktop -- this is
    # what makes it work against a wlroots compositor (Hyprland here) rather
    # than requiring GNOME Shell. Needs xdg-desktop-portal-hyprland, which
    # software-hyprland already wires up as the session's portal backend.
    services.gnome.gnome-remote-desktop.enable = lib.mkDefault true;

    # Multi-owner/additive: other services may open other ports here too.
    networking.firewall.allowedTCPPorts = [3389];
  };
}
