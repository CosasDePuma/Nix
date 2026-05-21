{lib, ...}: {
  flake = {
    darwinModules.settings-nixpkgs = {
      nixpkgs.config.allowUnfree = lib.mkDefault true;
    };

    nixosModules.settings-nixpkgs = {
      nixpkgs.config.allowUnfree = lib.mkDefault true;
    };
  };
}
