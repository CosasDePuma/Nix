{
  inputs,
  lib,
  ...
}: {
  flake = {
    darwinModules.software-opencode = {
      homebrew = {
        brews = ["opencode"];
        casks = ["opencode-desktop"];
      };
    };

    homeManagerModules.software-opencode = {pkgs, ...}: {
      imports = with inputs.self.homeManagerModules; [software-mcp];
      config = {
        home.packages = with pkgs; [opencode-desktop];
        programs.opencode = {
          enable = lib.mkDefault true;
          enableMcpIntegration = lib.mkDefault true;
          settings = {
            autoshare = lib.mkDefault false;
            autoupdate = lib.mkDefault true;
            plugin = lib.mkDefault ["@warp-dot-dev/opencode-warp"];
            permission = {
              bash = {
                "*" = lib.mkDefault "ask";
                "*sh" = lib.mkDefault "deny";
                "doas *" = lib.mkDefault "deny";
                "sh" = lib.mkDefault "deny";
                "su" = lib.mkDefault "deny";
                "sudo *" = lib.mkDefault "deny";
              };
              edit = lib.mkDefault "ask";
              external_directory = lib.mkDefault "deny";
              read = {
                "*" = lib.mkDefault "allow";
                "*.cert" = lib.mkDefault "deny";
                "*.crt" = lib.mkDefault "deny";
                "*.env" = lib.mkDefault "deny";
                "*.key" = lib.mkDefault "deny";
                "*.keystore" = lib.mkDefault "deny";
                "*.ovpn" = lib.mkDefault "deny";
                "*.p12" = lib.mkDefault "deny";
                "*.pem" = lib.mkDefault "deny";
                "*.pfx" = lib.mkDefault "deny";
                "*/.git/config" = lib.mkDefault "deny";
                "*/.aws/*" = lib.mkDefault "deny";
                "*/.gnupg/*" = lib.mkDefault "deny";
                "*/.kube/config" = lib.mkDefault "deny";
                "*/.ssh/*" = lib.mkDefault "deny";
                "*docker-compose*.yml" = lib.mkDefault "ask";
                "example.env" = lib.mkDefault "allow";
              };
              webfetch = lib.mkDefault "allow";
            };
          };
        };
      };
    };

    nixosModules.software-opencode = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        opencode
        opencode-desktop
      ];
    };
  };
}
