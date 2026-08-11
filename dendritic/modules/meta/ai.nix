{inputs, ...}: let
  aiModules = [
    "software-antigravity"
    "software-claude"
    "software-herdr"
    "software-ollama"
    "software-opencode"
    "software-openspec"
    "software-pi"
  ];
in {
  flake = {
    darwinModules.meta-ai = {
      imports = map (name: inputs.self.darwinModules.${name}) aiModules;
    };

    homeManagerModules.meta-ai = {
      imports = map (name: inputs.self.homeManagerModules.${name}) aiModules;
    };

    nixosModules.meta-ai = {
      imports = map (name: inputs.self.nixosModules.${name}) aiModules;
    };
  };
}
