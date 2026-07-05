_: {
  flake = {
    homeManagerModules.software-quickshell = {pkgs, ...}: {
      home.packages = with pkgs; [quickshell];
    };

    nixosModules.software-quickshell = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [quickshell];
    };
  };
}
