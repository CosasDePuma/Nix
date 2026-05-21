{lib, ...}: {
  # TODO: SSH Config
  flake.modules = {
    homeManager.software-ssh = {
      services.ssh-agent.enable = lib.mkDefault true;
    };
  };
}
