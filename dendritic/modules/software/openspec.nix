_: {
  flake = {
    darwinModules.software-openspec = {
      homebrew.brews = ["openspec"];
    };

    homeManagerModules.software-openspec = {pkgs, ...}: {
      home.packages = [pkgs.openspec];
    };

    nixosModules.software-openspec = {pkgs, ...}: {
      environment.systemPackages = [pkgs.openspec];
    };
  };
}
