{lib, ...}: {
  flake.nixosModules.service-hyprlock = {pkgs, ...}: {
    environment.systemPackages = [pkgs.hyprlock];

    # hyprlock authenticates directly against PAM; without a registered
    # PAM service for it, unlocking always fails.
    security.pam.services.hyprlock = lib.mkDefault {};
  };
}
