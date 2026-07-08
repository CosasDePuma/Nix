{lib, ...}: {
  flake.nixosModules.gpu-nvidia = {config, ...}: {
    boot = {
      initrd.kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
      kernelParams = ["nvidia-drm.modeset=1"];
    };
    environment.sessionVariables = {
      __GLX_VENDOR_LIBRARY_NAME = lib.mkDefault "nvidia";
      GBM_BACKEND = lib.mkDefault "nvidia-drm";
      LIBVA_DRIVER_NAME = lib.mkDefault "nvidia";
    };
    hardware = {
      nvidia = {
        modesetting.enable = lib.mkDefault true;
        package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.latest;
        powerManagement = {
          enable = lib.mkDefault false;
          finegrained = lib.mkDefault false;
        };
        open = lib.mkDefault true;
        nvidiaSettings = lib.mkDefault true;
      };
      graphics = {
        enable = lib.mkDefault true;
        enable32Bit = lib.mkDefault true;
      };
    };
    services.xserver.videoDrivers = ["nvidia"];
  };
}
