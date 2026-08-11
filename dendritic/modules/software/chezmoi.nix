_: {
  flake = {
    darwinModules.software-chezmoi = {
      homebrew.brews = ["chezmoi"];
    };

    homeManagerModules.software-chezmoi = {pkgs, ...}: {
      home.packages = with pkgs; [chezmoi];
    };

    nixosModules.software-chezmoi = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [chezmoi];
    };
  };
}
