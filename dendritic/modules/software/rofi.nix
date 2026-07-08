{lib, ...}: {
  flake = {
    homeManagerModules.software-rofi = {
      programs.rofi.enable = lib.mkDefault true;
    };

    nixosModules.software-rofi = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [rofi];
    };
  };
}
