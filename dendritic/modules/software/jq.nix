{lib, ...}: {
  flake = {
    darwinModules.software-jq = {
      homebrew.brews = ["jq"];
    };

    homeManagerModules.software-jq = {
      programs.jq.enable = lib.mkDefault true;
    };

    nixosModules.software-jq = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [jq];
    };
  };
}
