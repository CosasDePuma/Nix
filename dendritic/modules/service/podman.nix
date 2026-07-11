{lib, ...}: {
  flake.nixosModules.service-podman = {
    virtualisation = {
      podman = {
        enable = lib.mkDefault true;
        autoPrune = {
          enable = lib.mkDefault true;
          dates = lib.mkDefault "weekly";
          flags = lib.mkDefault ["--all"];
        };
        dockerCompat = lib.mkDefault true;
      };
      oci-containers.backend = lib.mkDefault "podman";
    };
  };
}
