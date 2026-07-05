{lib, ...}: {
  flake = {
    homeManagerModules.software-hyprland = _: {
      wayland.windowManager.hyprland.enable = lib.mkDefault true;
    };

    nixosModules.software-hyprland = {
      programs.hyprland.enable = lib.mkDefault true;
    };
  };
}
