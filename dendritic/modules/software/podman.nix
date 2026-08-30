{lib, ...}: {
  flake = {
    darwinModules.software-podman = {
      homebrew = {
        brews = ["podman" "podman-compose"];
        casks = ["podman-desktop"];
      };
    };

    homeManagerModules.software-podman = {pkgs, ...}: {
      home.packages = with pkgs; [podman-compose];
    };

    nixosModules.software-podman = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [podman-compose];
      virtualisation.podman = {
        autoPrune.enable = lib.mkDefault true;
        dockerCompat = lib.mkDefault true;
        dockerSocket.enable = lib.mkDefault true;
        enable = lib.mkDefault true;
        # netavark's built-in DNS resolves containers by name on the default
        # network, so containers can reach each other by container name
        # without hand-rolling a dedicated podman network to get the same
        # thing docker-compose gives for free.
        defaultNetwork.settings.dns_enabled = lib.mkDefault true;
      };
      virtualisation.oci-containers.backend = lib.mkDefault "podman";
    };
  };
}
