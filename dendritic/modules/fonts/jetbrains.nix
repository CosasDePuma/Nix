_: {
  flake = {
    darwinModules.fonts-jetbrains = {
      homebrew.casks = ["font-jetbrains-mono-nerd-font"];
    };

    nixosModules.fonts-jetbrains = {pkgs, ...}: {
      fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
    };
  };
}
