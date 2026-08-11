{lib, ...}: {
  flake = {
    darwinModules.software-ollama = {
      homebrew.brews = ["ollama"];
    };

    nixosModules.software-ollama = {
      services.ollama.enable = lib.mkDefault true;
    };
  };
}
