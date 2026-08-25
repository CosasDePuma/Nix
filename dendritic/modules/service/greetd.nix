{lib, ...}: {
  flake.nixosModules.service-greetd = {pkgs, ...}: {
    # tuigreet: a terminal greeter holds no seat/DRM master, unlike GDM's
    # Wayland greeter, which races the session for DRM. It lists whatever
    # sessions are installed under wayland-sessions, so nothing here is
    # tied to a specific compositor.
    services.greetd = {
      enable = lib.mkDefault true;
      settings.default_session.command = lib.mkDefault "${pkgs.tuigreet}/bin/tuigreet --time --sessions /run/current-system/sw/share/wayland-sessions --remember";
    };
  };
}
