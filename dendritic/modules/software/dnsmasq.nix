_: {
  flake.nixosModules.software-dnsmasq = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [dnsmasq];
  };
}
