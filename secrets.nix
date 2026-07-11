let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos";
  vm-homelab = {
    automation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5MEUY8ks+UAOo3u2EeLEsoJX1yK6nki5hZ7jhuj7NZ @homelab.automation";
    media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxJgKzncwws+pz1JJxPO2TOdU1Qvvi/IwByMHrBwTw7 @homelab.media";
    proxy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxYJhovcbELqZzBf+NR95qNRBa003w7kZtqpWEwr7bP @homelab.proxy";
    router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnVQKprt/2/Tj+00/MUemfNJ1XalPmz5LJABFGUxSLF @homelab.router";
  };
in {
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Automation                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "dendritic/hosts/homelab/services/.smb/smb.creds.age".publicKeys = [
    nixos
    vm-homelab.automation
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
    vm-homelab.proxy
  ];
  "dendritic/hosts/homelab/services/.homepage/homepage.env.age".publicKeys = [
    nixos
    vm-homelab.proxy
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
