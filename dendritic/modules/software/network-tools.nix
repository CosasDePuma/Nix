_: {
  flake = {
    homeManagerModules.software-network-tools = {pkgs, ...}: {
      home.packages = with pkgs; [dig iperf tcpdump];
    };

    nixosModules.software-network-tools = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [dig iperf tcpdump];
    };
  };
}
