{lib, ...}: {
  flake = {
    homeManagerModules.settings-gtk = _: {
      gtk.enable = lib.mkDefault true;
    };

    nixosModules.settings-gtk = _: {
      # Backs home-manager's gtk module: without the system dconf D-Bus
      # service, its dconf.settings writes (gtk-theme/icon-theme/
      # color-scheme, derived from gtk.theme/iconTheme/colorScheme) are
      # inert.
      programs.dconf.enable = lib.mkDefault true;
    };
  };
}
