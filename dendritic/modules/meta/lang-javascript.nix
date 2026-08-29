{inputs, ...}: let
  langModules = [
    "software-bun"
    "software-node"
  ];
in {
  flake = {
    darwinModules.meta-lang-javascript = {
      imports = map (name: inputs.self.darwinModules.${name}) langModules;
    };

    homeManagerModules.meta-lang-javascript = {
      imports = map (name: inputs.self.homeManagerModules.${name}) langModules;
    };

    nixosModules.meta-lang-javascript = {
      imports = map (name: inputs.self.nixosModules.${name}) langModules;
    };
  };
}
