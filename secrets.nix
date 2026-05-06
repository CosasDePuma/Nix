let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos";
  vm-homelab = {
    automation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5MEUY8ks+UAOo3u2EeLEsoJX1yK6nki5hZ7jhuj7NZ @homelab.automation";
    media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxJgKzncwws+pz1JJxPO2TOdU1Qvvi/IwByMHrBwTw7 @homelab.media";
    proxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxYJhovcbELqZzBf+NR95qNRBa003w7kZtqpWEwr7bP @homelab.proxy";
    router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMH4o2Q4cwq9GvJ2+MgErC5Odtf+WPbvz3H7KbOyOhoA @homelab.router";
  };
in
{
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Automation                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "modules/hosts/automation/.smb/smb.creds.age".publicKeys = [
    nixos
    vm-homelab.automation
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Media                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "modules/hosts/media/.smb/smb.creds.age".publicKeys = [
    nixos
    vm-homelab.media
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Proxy                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "modules/hosts/proxy/.acme/acme.env.age".publicKeys = [
    nixos
    vm-homelab.proxy
  ];
  "modules/hosts/proxy/.homepage/homepage.env.age".publicKeys = [
    nixos
    vm-homelab.proxy
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Router                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "modules/hosts/router/.ddclient/cloudflare.key.age".publicKeys = [
    nixos
    vm-homelab.router
  ];
  "modules/hosts/router/.wireguard/wireguard-profiles.conf.age".publicKeys = [ nixos ];
  "modules/hosts/router/.wireguard/wireguard.key.age".publicKeys = [
    nixos
    vm-homelab.router
  ];
}
