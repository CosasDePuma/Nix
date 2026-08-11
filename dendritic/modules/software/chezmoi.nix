_: {
  flake = {
    darwinModules.software-chezmoi = {
      homebrew.brews = ["chezmoi"];
    };

    homeManagerModules.software-chezmoi = {
      lib,
      pkgs,
      ...
    }: {
      home.packages = with pkgs; [chezmoi];
      xdg.configFile."chezmoi/chezmoi.toml" = {
        text = lib.mkDefault ''
          [bitwarden]
          unlock = "auto"
        '';
      };
    };

    nixosModules.software-chezmoi = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [chezmoi];
    };
  };
}
