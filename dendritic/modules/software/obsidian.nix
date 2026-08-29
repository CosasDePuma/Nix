_: {
  flake = {
    darwinModules.software-obsidian = {
      homebrew.casks = ["obsidian"];
    };

    nixosModules.software-obsidian = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [obsidian];
    };
  };
}
