_: {
  flake = {
    homeManagerModules.software-nemo = {pkgs, ...}: {
      home.packages = with pkgs; [nemo];
    };

    nixosModules.software-nemo = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [nemo];
    };
  };
}
