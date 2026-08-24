{lib, ...}: {
  flake = {
    darwinModules.fonts-jetbrains = {
      homebrew.casks = ["font-jetbrains-mono-nerd-font"];
    };

    # Omarchy ships JetBrainsMono Nerd Font as both the terminal and system
    # font by default (default/fontconfig/conf.avail/50-omarchy.conf aliases
    # monospace -> "JetBrainsMono Nerd Font"). Anything that resolves the
    # generic "monospace" family -- including the omarchy-shell bar itself --
    # picks this up for free once it's the fontconfig default.
    homeManagerModules.fonts-jetbrains = {pkgs, ...}: {
      fonts.fontconfig = {
        enable = lib.mkDefault true;
        defaultFonts.monospace = lib.mkDefault ["JetBrainsMono Nerd Font"];
      };
      home.packages = [pkgs.nerd-fonts.jetbrains-mono];
    };

    nixosModules.fonts-jetbrains = {pkgs, ...}: {
      fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
      fonts.fontconfig.defaultFonts.monospace = lib.mkDefault ["JetBrainsMono Nerd Font"];
    };
  };
}
