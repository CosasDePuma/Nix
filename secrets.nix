let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos";
  vm-homelab = {
    automation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5MEUY8ks+UAOo3u2EeLEsoJX1yK6nki5hZ7jhuj7NZ @homelab.automation";
    media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBekVv5frPrfFD9JtEJGZp7YXmq3HqjGdZiznseUXgv root@media";
    router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnVQKprt/2/Tj+00/MUemfNJ1XalPmz5LJABFGUxSLF @homelab.router";
    services = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGilrsstiK7+oQVu0dQxuSOV5Y/ooge99afqDOPnC3pd root@paradis";
    work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDx0Lv1z58633FZ92WeCtiXsJhu2pJ8G77ZqVdhKN3d7 root@work";
  };
in {
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Automation                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "dendritic/hosts/homelab/services/.smb/smb.creds.age".publicKeys = [
    nixos
    vm-homelab.services
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Media                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "dendritic/hosts/homelab/media/.smb/smb.creds.age".publicKeys = [
    nixos
    vm-homelab.media
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Proxy                   ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "dendritic/hosts/homelab/services/.acme/acme.env.age".publicKeys = [
    nixos
    vm-homelab.services
  ];
  "dendritic/hosts/homelab/services/.homepage/homepage.env.age".publicKeys = [
    nixos
    vm-homelab.services
  ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Router                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "dendritic/hosts/homelab/router/.ddclient/cloudflare.key.age".publicKeys = [
    nixos
    vm-homelab.router
  ];
  "dendritic/hosts/homelab/router/.wireguard/wireguard-profiles.conf.age".publicKeys = [nixos];
  "dendritic/hosts/homelab/router/.wireguard/wireguard.key.age".publicKeys = [
    nixos
    vm-homelab.router
  ];
}
