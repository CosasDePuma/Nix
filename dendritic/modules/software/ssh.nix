{lib, ...}: {
  # TODO: SSH Config
  flake = {
    darwinModules.software-ssh = {
      programs.ssh.startAgent = lib.mkDefault true;
    };

    homeManagerModules.software-ssh = {
      services.ssh-agent.enable = lib.mkDefault true;
    };

    nixosModules.software-ssh = {
      programs.ssh.startAgent = lib.mkDefault true;
    };
  };
}
