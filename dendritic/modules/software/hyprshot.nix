_: {
  flake = {
    homeManagerModules.software-hyprshot = {pkgs, ...}: {
      home.packages = with pkgs; [hyprshot];
    };

    nixosModules.software-hyprshot = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [hyprshot];
    };
  };
}
