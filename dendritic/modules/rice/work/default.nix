{
  inputs,
  ...
}: {
  flake = {
    homeManagerModules.rice-work = {
      imports = [
        inputs.self.homeManagerModules.software-hyprland
      ];
    };

    nixosModules.rice-work = {
      imports = [
        inputs.self.nixosModules.software-hyprland
      ];
    };
  };
}
