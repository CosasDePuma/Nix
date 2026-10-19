{lib, ...}: {
  flake.nixosModules.software-docker = {
    virtualisation.docker = {
      autoPrune.enable = lib.mkDefault true;
      enable = lib.mkDefault true;
    };
    virtualisation.oci-containers.backend = lib.mkDefault "docker";
  };
}
