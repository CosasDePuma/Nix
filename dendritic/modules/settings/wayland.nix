{lib, ...}: {
  flake = {
    homeManagerModules.settings-wayland = _: {
      home.sessionVariables = {
        NIXOS_OZONE_WL = lib.mkDefault "1";
        XDG_SESSION_TYPE = lib.mkDefault "wayland";
        GDK_BACKEND = lib.mkDefault "wayland,x11,*";
        QT_QPA_PLATFORM = lib.mkDefault "wayland;xcb";
        SDL_VIDEODRIVER = lib.mkDefault "wayland";
        CLUTTER_BACKEND = lib.mkDefault "wayland";
      };
    };

    nixosModules.settings-wayland = _: {
      environment.sessionVariables = {
        NIXOS_OZONE_WL = lib.mkDefault "1";
        XDG_SESSION_TYPE = lib.mkDefault "wayland";
        GDK_BACKEND = lib.mkDefault "wayland,x11,*";
        QT_QPA_PLATFORM = lib.mkDefault "wayland;xcb";
        SDL_VIDEODRIVER = lib.mkDefault "wayland";
        CLUTTER_BACKEND = lib.mkDefault "wayland";
      };
    };
  };
}
