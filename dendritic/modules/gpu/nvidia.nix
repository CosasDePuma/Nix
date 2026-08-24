{lib, ...}: {
  flake.nixosModules.gpu-nvidia = _: {
    # CUDA-dependent packages (e.g. ollama-cuda) aren't built for
    # cache.nixos.org -- unfree, and the official cache doesn't build unfree
    # packages. Without this, anything that pulls one in compiles llama.cpp's
    # CUDA kernels from scratch locally, which is a very long build.
    # Multi-owner/additive: other modules may add other substituters.
    nix.settings = {
      substituters = ["https://cuda-maintainers.cachix.org"];
      trusted-public-keys = ["cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="];
    };

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
