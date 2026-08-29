_: {
  flake = {
    darwinModules.software-office = {
      homebrew.casks = ["microsoft-word" "microsoft-excel" "microsoft-powerpoint"];
    };

    # LibreOffice is the open-source office suite for Linux; Microsoft Office is
    # not packaged for NixOS.
    homeManagerModules.software-office = {pkgs, ...}: {
      home.packages = with pkgs; [libreoffice];
    };

    nixosModules.software-office = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [libreoffice];
    };
  };
}
