let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos";
  vm-dmz.router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMH4o2Q4cwq9GvJ2+MgErC5Odtf+WPbvz3H7KbOyOhoA @dmz.router";
  vm-homelab = {
    automation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5MEUY8ks+UAOo3u2EeLEsoJX1yK6nki5hZ7jhuj7NZ @homelab.automation";
    media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxJgKzncwws+pz1JJxPO2TOdU1Qvvi/IwByMHrBwTw7 @homelab.media";
    proxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxYJhovcbELqZzBf+NR95qNRBa003w7kZtqpWEwr7bP @homelab.proxy";
  };
  vm-gaming = {
    wow = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXUfKnAvMWzm+shaqVGF8b8KIXpvH2b+N3DNXVWZk1q @gaming.wow";
  };
in
{
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Automation                ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/homelab/automation/samba.creds.age".publicKeys = [
    nixos
    vm-homelab.automation
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Media                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/homelab/media/samba.creds.age".publicKeys = [
    nixos
    vm-homelab.media
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Proxy                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/homelab/proxy/acme.env.age".publicKeys = [
    nixos
    vm-homelab.proxy
  ];
  "systems/x86_64-linux/homelab/proxy/homepage.env.age".publicKeys = [
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

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                    WoW                    ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/gaming/wow/samba.creds.age".publicKeys = [
    nixos
    vm-gaming.wow
  ];
}
