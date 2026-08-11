{
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
}
