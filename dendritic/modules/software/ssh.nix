{lib, ...}: {
  # TODO: SSH Config
  flake = {
    homeManagerModules.software-ssh = {
      services.ssh-agent.enable = lib.mkDefault true;
    };
  };
}
