{
  flake = {
    # On macOS Burp Suite ships as a single desktop client (Community and
    # Professional share the same app); signing in with an active PortSwigger
    # Professional subscription unlocks the Pro features. This is the smoothest
    # way to run Burp Suite Pro on nix-darwin.
    darwinModules.software-burpsuite = {
      homebrew.casks = ["burp-suite"];
    };

    homeManagerModules.software-burpsuite = {pkgs, ...}: {
      home.packages = with pkgs; [burpsuite];
    };

    nixosModules.software-burpsuite = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [burpsuite];
    };
  };
}
