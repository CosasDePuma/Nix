{lib, ...}: {
  flake = {
    darwinModules.software-ollama = {
      homebrew.brews = ["ollama"];
    };

    homeManagerModules.software-ollama = {osConfig, ...}: {
      services.ollama = {
        enable = lib.mkDefault true;
        acceleration = lib.mkDefault (
          if builtins.elem "nvidia" (osConfig.boot.initrd.kernelModules or [])
          then "cuda"
          else null
        );
      };
    };

    nixosModules.software-ollama = {
      config,
      pkgs,
      ...
    }: {
      services.ollama = {
        enable = lib.mkDefault true;
        package = lib.mkDefault (
          if builtins.elem "nvidia" (config.boot.initrd.kernelModules or [])
          then pkgs.ollama-cuda
          else pkgs.ollama
        );
      };
    };
  };
}
