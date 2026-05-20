{lib, ...}: {
  flake.modules.nixos.nvidia-drivers = {pkgs, ...}: {
    boot.kernelParams = ["nvidia-drm.modeset=1"];
    environment.sessionVariables = {
      __GLX_VENDOR_LIBRARY_NAME = lib.mkDefault "nvidia";
      GBM_BACKEND = lib.mkDefault "nvidia-drm";
      LIBVA_DRIVER_NAME = lib.mkDefault "nvidia";
    };
    hardware.nvidia = {
      modesetting.enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.linuxPackages.nvidiaPackages.latest;
      powerManagement = {
        enable = lib.mkDefault false;
        finegrained = lib.mkDefault false;
      };
      open = lib.mkDefault true;
      nvidiaSettings = lib.mkDefault true;
    };
    graphics = {
      enable = lib.mkDefault true;
      enable32bit = lib.mkDefault true;
    };
    xserver.videoDrivers = ["nvidia"];
  };
}
