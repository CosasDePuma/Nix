{lib, ...}: {
  flake = {
    darwinModules.fonts-jetbrains = {
      homebrew.casks = ["font-jetbrains-mono-nerd-font"];
    };

    homeManagerModules.fonts-jetbrains = {pkgs, ...}: {
      fonts.fontconfig.enable = lib.mkDefault true;
      home.packages = [pkgs.nerd-fonts.jetbrains-mono];
    };

    nixosModules.fonts-jetbrains = {pkgs, ...}: {
      fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
    };
  };
}
