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
      };
    };
  };
}
