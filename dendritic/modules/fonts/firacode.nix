{lib, ...}: {
  flake = {
    darwinModules.fonts-firacode = {
      homebrew.casks = ["font-fira-code-nerd-font"];
    };

    homeManagerModules.fonts-firacode = {pkgs, ...}: {
      fonts.fontconfig.enable = lib.mkDefault true;
      home.packages = [pkgs.nerd-fonts.fira-code];
    };

    nixosModules.fonts-firacode = {pkgs, ...}: {
      fonts.packages = [pkgs.nerd-fonts.fira-code];
    };
  };
}
