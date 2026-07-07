{
  inputs,
  lib,
  ...
}: {
  flake = {
    homeManagerModules.rice-gaming = {
      imports = [
        inputs.self.homeManagerModules.software-hyprland
      ];
    };

    nixosModules.rice-gaming = {pkgs, ...}: {
      imports = [
        inputs.self.nixosModules.software-hyprland
      ];

      environment = {
        sessionVariables = {
          GAMEMODERUNEXEC = "1";
          MANGOHUD = "1";
          PROTON_ENABLE_WAYLAND = "1";
          PROTON_USE_WINED3D = "0";
          SDL_VIDEODRIVER = "wayland";
          STEAM_USE_WAYLAND = "1";
        };
        systemPackages = with pkgs; [
          gamemode
          mangohud
          wayland
        ];
      };

      programs.steam = {
        dedicatedServer.openFirewall = lib.mkDefault true;
        enable = lib.mkDefault true;
        extraCompatPackages = with pkgs; [proton-ge-bin];
        remotePlay.openFirewall = lib.mkDefault true;
      };
    };
  };
}
