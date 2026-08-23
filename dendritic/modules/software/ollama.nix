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
        user = lib.mkDefault "ollama";
        package = lib.mkDefault (
          if builtins.elem "nvidia" (config.boot.initrd.kernelModules or [])
          then pkgs.ollama-cuda
          else pkgs.ollama
        );
      };

      # Upstream sets DynamicUser=true unconditionally, whose StateDirectory
      # migration to /var/lib/private fails against impermanence bind-mounts.
      systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

      # ReadWritePaths includes the models dir, which must exist before the
      # service's namespace setup runs.
      systemd.tmpfiles.rules = [
        "d ${config.services.ollama.models} 0700 ${config.services.ollama.user} ${config.services.ollama.group} -"
      ];
    };
  };
}
