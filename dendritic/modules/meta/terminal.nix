{inputs, ...}: let
  terminalModules = [
    "software-bat"
    "software-curl"
    "software-direnv"
    "software-git"
    "software-jq"
    "software-lsd"
    "software-ssh"
    "software-starship"
    "software-wget"
    "software-zoxide"
    "software-zsh"
  ];
in {
  flake = {
    darwinModules.meta-terminal = {
      imports = map (name: inputs.self.darwinModules.${name}) terminalModules;
    };

    homeManagerModules.meta-terminal = {
      imports = map (name: inputs.self.homeManagerModules.${name}) (terminalModules ++ ["software-hushlogin"]);
    };

    nixosModules.meta-terminal = {
      imports = map (name: inputs.self.nixosModules.${name}) terminalModules;
    };
  };
}
