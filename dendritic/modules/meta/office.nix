{inputs, ...}: let
  officeModules = [
    "software-office"
    "software-outlook"
    "software-teams"
  ];
in {
  flake = {
    darwinModules.meta-office = {
      imports = map (name: inputs.self.darwinModules.${name}) officeModules;
    };

    homeManagerModules.meta-office = {
      imports = map (name: inputs.self.homeManagerModules.${name}) ["software-office" "software-teams"];
    };

    nixosModules.meta-office = {
      imports = map (name: inputs.self.nixosModules.${name}) ["software-office" "software-teams"];
    };
  };
}
