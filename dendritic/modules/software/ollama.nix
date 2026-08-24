{lib, ...}: {
  flake = {
    darwinModules.software-ollama = {
      homebrew.brews = ["ollama"];
    };

    homeManagerModules.software-ollama = {osConfig, ...}: {
      # A NixOS system-level ollama (nixosModules.software-ollama) already
      # binds 127.0.0.1:11434; running the home-manager one too fails with
      # "address already in use" for whichever starts second. Only default
      # this one on when there's no system-level ollama to collide with
      # (e.g. Darwin, where software-ollama has no service of its own).
      services.ollama = {
        enable = lib.mkDefault (!(osConfig.services.ollama.enable or false));
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
        "d ${config.services.ollama.modelsDir} 0700 ${config.services.ollama.user} ${config.services.ollama.group} -"
      ];
    };
  };
}
