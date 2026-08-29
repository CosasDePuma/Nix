let
  pumita = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKh1YtKaItcNzC3RGez38zaJ0geelyrb6AFV73OqLchv pumita";
  vmHomelabRouter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSv8kVRKNzpltMOS4/aI6Tv2pqG7++zFpXFJygQkAT3 root@router";
  #
  #  vm-homelab = {
  #    automation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5MEUY8ks+UAOo3u2EeLEsoJX1yK6nki5hZ7jhuj7NZ @homelab.automation";
  #    media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBekVv5frPrfFD9JtEJGZp7YXmq3HqjGdZiznseUXgv root@media";
  #    router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnVQKprt/2/Tj+00/MUemfNJ1XalPmz5LJABFGUxSLF @homelab.router";
  #    services = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGilrsstiK7+oQVu0dQxuSOV5Y/ooge99afqDOPnC3pd root@paradis";
  #    work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDx0Lv1z58633FZ92WeCtiXsJhu2pJ8G77ZqVdhKN3d7 root@work";
  #  };
in {
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                Automation                 ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  #   "modules/hosts/automation/.smb/smb.creds.age".publicKeys = [
  #     nixos
  #     vm-homelab.automation
  #   ];

  #   # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  #   # ┃                   Media                   ┃
  #   # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  #   "modules/hosts/media/.smb/smb.creds.age".publicKeys = [
  #     nixos
  #     vm-homelab.media
  #   ];

  #   # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  #   # ┃                   Proxy                   ┃
  #   # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  #   "modules/hosts/proxy/.acme/acme.env.age".publicKeys = [
  #     nixos
  #     vm-homelab.proxy
  #   ];
  #   "modules/hosts/proxy/.homepage/homepage.env.age".publicKeys = [
  #     nixos
  #     vm-homelab.proxy
  #   ];

  #   # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  #   # ┃                   Router                  ┃
  #   # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  #   "modules/hosts/router/.ddclient/cloudflare.key.age".publicKeys = [
  #     nixos
  #     vm-homelab.router
  #   ];
  #   "modules/hosts/router/.wireguard/wireguard-profiles.conf.age".publicKeys = [nixos];
  #   "modules/hosts/router/.wireguard/wireguard.key.age".publicKeys = [
  #     nixos
  #     vm-homelab.router
  #   ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Router                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "dendritic/hosts/homelab/x86_64-linux/router/.ddclient/cloudflare-key.age".publicKeys = [pumita vmHomelabRouter];
  "dendritic/hosts/homelab/x86_64-linux/router/.wireguard/wireguard-key.age".publicKeys = [pumita vmHomelabRouter];
  # Client-side WireGuard profiles (not consumed by the router itself, kept
  # here as a decrypt-with-pumita-only backup for re-provisioning devices).
  "dendritic/hosts/homelab/x86_64-linux/router/.wireguard/wireguard-profiles.conf.age".publicKeys = [pumita];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                 Profiles                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  # --- cosasdepuma
  "dendritic/modules/profile/cosasdepuma/.ssh/keys/homelab.age".publicKeys = [pumita];
  "dendritic/modules/profile/cosasdepuma/.ssh/keys/pumita.age".publicKeys = [pumita];

  # --- work
  "dendritic/modules/profile/work/.ssh/config.d/work.age".publicKeys = [pumita];
  "dendritic/modules/profile/work/.ssh/keys/work.age".publicKeys = [pumita];
}
