_: {
  flake = {
    darwinModules.software-unar = {
      homebrew.casks = ["the-unarchiver"];
    };

    homeManagerModules.software-unar = {pkgs, ...}: {
      home.packages = with pkgs; [unar];
    };

    nixosModules.software-unar = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [unar];
    };
  };
}
