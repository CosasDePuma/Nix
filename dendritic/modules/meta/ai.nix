{inputs, ...}: let
  aiModules = [
    # keep-sorted start
    "software-antigravity"
    "software-chatgpt"
    "software-claude"
    "software-herdr"
    "software-ollama"
    "software-opencode"
    "software-openspec"
    "software-pi"
    # keep-sorted end
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
