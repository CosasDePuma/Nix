_: {
  flake = {
    darwinModules.fonts-firacode = {
      homebrew.casks = ["font-fira-code-nerd-font"];
    };

    nixosModules.fonts-firacode = {pkgs, ...}: {
      fonts.packages = [pkgs.nerd-fonts.fira-code];
    };
  };
}
