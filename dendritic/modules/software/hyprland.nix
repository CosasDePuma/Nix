{lib, ...}: {
  flake = {
    homeManagerModules.software-hyprland = {
      wayland.windowManager.hyprland.enable = lib.mkDefault true;
    };

    nixosModules.software-hyprland = {
      programs.hyprland.enable = lib.mkDefault true;
    };
  };
}
