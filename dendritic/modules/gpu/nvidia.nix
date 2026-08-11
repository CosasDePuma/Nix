{lib, ...}: {
  flake.nixosModules.gpu-nvidia = _: {
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
        branch = lib.mkDefault "production";
        forceFullCompositionPipeline = lib.mkDefault true;
        modesetting.enable = lib.mkDefault true;
        nvidiaPersistenced = lib.mkDefault true;
        nvidiaSettings = lib.mkDefault true;
        open = lib.mkDefault true;
        powerManagement = {
          enable = lib.mkDefault false;
          finegrained = lib.mkDefault false;
        };
        videoAcceleration = lib.mkDefault true;
      };
      graphics = {
        enable = lib.mkDefault true;
        enable32Bit = lib.mkDefault true;
      };
    };
    services.xserver.videoDrivers = ["nvidia"];
  };
}
