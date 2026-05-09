{lib, ...}: {
  # TODO: SSH Config
  flake.modules = {
    homeManager.ssh-software = _: {
      services.ssh-agent.enable = lib.mkDefault true;
    };

    nixos.ssh-software = _: {
    };
  };
}
