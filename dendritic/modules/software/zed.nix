{lib, ...}: {
  flake = {
    darwinModules.software-zed = {
      homebrew.casks = ["zed"];
    };

    homeManagerModules.software-zed = {
      config.programs.zed-editor = {
        enable = lib.mkDefault true;
        extensions = ["nix"];
      };
    };

    nixosModules.software-zed = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [zed-editor];
    };
  };
}
