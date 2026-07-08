_: {
  flake = {
    darwinModules.software-socat = {
      homebrew.brews = ["socat"];
    };

    homeManagerModules.software-socat = {pkgs, ...}: {
      home.packages = with pkgs; [socat];
    };

    nixosModules.software-socat = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [socat];
    };
  };
}
