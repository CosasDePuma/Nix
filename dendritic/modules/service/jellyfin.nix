{
  lib,
  pkgs,
  ...
}: {
  flake.nixosModules.service-jellyfin = {
    services.jellyfin = {
      enable = lib.mkDefault true;
      openFirewall = lib.mkDefault true;
    };

    environment.systemPackages = with pkgs; [
      jellyfin-ffmpeg
      jellyfin-web
      mediainfo
    ];
  };
}
