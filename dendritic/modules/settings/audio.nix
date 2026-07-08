{lib, ...}: {
  flake.nixosModules.settings-audio = {
    services = {
      pipewire = {
        enable = lib.mkDefault true;
        alsa = {
          enable = lib.mkDefault true;
          support32Bit = lib.mkDefault true;
        };
        pulse.enable = lib.mkDefault true;
      };
      pulseaudio.enable = lib.mkDefault false;
    };
  };
}
