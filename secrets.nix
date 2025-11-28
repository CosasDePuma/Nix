let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos";
  vm-dmz.router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMH4o2Q4cwq9GvJ2+MgErC5Odtf+WPbvz3H7KbOyOhoA @dmz.router";
  vm-homelab = {
    media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxJgKzncwws+pz1JJxPO2TOdU1Qvvi/IwByMHrBwTw7 @homelab.media";
    proxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxYJhovcbELqZzBf+NR95qNRBa003w7kZtqpWEwr7bP @homelab.proxy";
  };
in
{
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Media                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/homelab/media/.smb/smb.creds.age".publicKeys = [
    nixos
    vm-homelab.media
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Proxy                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/homelab/proxy/.acme/acme.env.age".publicKeys = [
    nixos
    vm-homelab.proxy
  ];
  "systems/x86_64-linux/homelab/proxy/.homepage/homepage.env.age".publicKeys = [
    nixos
    vm-homelab.proxy
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Router                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/dmz/router/.ddclient/cloudflare.key.age".publicKeys = [
    nixos
    vm-dmz.router
  ];
  "systems/x86_64-linux/dmz/router/.wireguard/wireguard-profiles.conf.age".publicKeys = [ nixos ];
  "systems/x86_64-linux/dmz/router/.wireguard/wireguard.key.age".publicKeys = [
    nixos
    vm-dmz.router
  ];
}
