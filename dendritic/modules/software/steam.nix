{lib, ...}: {
  flake = {
    darwinModules.software-steam = {
      homebrew.casks = ["steam"];
    };

    nixosModules.software-steam = {
      programs.steam.enable = lib.mkDefault true;
    };
  };
}
