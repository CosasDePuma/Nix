{lib, ...}: {
  flake.nixosModules.network-interfaces = {
    networking.usePredictableInterfaceNames = lib.mkDefault false;
  };
}
