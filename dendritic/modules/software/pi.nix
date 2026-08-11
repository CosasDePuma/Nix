{lib, ...}: {
  flake = {
    darwinModules.software-pi = {
      homebrew.brews = ["pi-coding-agent"];
    };

    homeManagerModules.software-pi = {
      programs.pi-coding-agent.enable = lib.mkDefault true;
    };

    nixosModules.software-pi = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [pi-coding-agent];
    };
  };
}
