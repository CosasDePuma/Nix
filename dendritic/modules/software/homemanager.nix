{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-homemanager = {config, ...}: {
      imports = [inputs.home-manager.darwinModules.default];
      config = lib.mkMerge [
        {
          home-manager = {
            useGlobalPkgs = lib.mkDefault true;
            useUserPackages = lib.mkDefault true;
            backupFileExtension = lib.mkDefault "bak";
          };
        }
        (lib.mkIf (config.system.primaryUser != null) {
          users.users.${config.system.primaryUser}.home = lib.mkDefault "/Users/${config.system.primaryUser}";
        })
      ];
    };

    nixosModules.software-homemanager = {
      imports = [inputs.home-manager.nixosModules.default];
      config.home-manager = {
        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;
        backupFileExtension = lib.mkDefault "bak";
      };
    };
  };
}
