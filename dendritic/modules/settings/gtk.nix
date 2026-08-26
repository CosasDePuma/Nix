{lib, ...}: {
  flake = {
    homeManagerModules.settings-gtk = {pkgs, ...}: {
      gtk.enable = lib.mkDefault true;
      home.packages = [pkgs.gtk3];
    };

    nixosModules.settings-gtk = {pkgs, ...}: {
      # Backs home-manager's gtk module: without the system dconf D-Bus
      # service, its dconf.settings writes (gtk-theme/icon-theme/
      # color-scheme, derived from gtk.theme/iconTheme/colorScheme) are
      # inert.
      programs.dconf.enable = lib.mkDefault true;
      environment.systemPackages = [pkgs.gtk3];
    };
  };
}
