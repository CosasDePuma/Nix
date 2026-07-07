_: {
  flake = {
    nixosModules.software-firefox = {
      programs.firefox.enable = true;
    };

    darwinModules.software-firefox = {
      homebrew.casks = ["firefox"];
    };
  };
}
