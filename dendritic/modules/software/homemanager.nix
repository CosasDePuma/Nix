{inputs, ...}: {
  flake.nixosModules.software-homemanager = {
    imports = [inputs.home-manager.nixosModules.default];
    config.home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
    };
  };
}
