{lib, ...}: {
  flake.nixosModules.service-jellyfin = {pkgs, ...}: {
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
