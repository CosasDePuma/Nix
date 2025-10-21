let
  audea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9Dt0O0OJokuV6x1jcejmHvJiGT8ZEubd5/aHGYEyUi audea";
  vm-router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0IKhoSi8qn1yWaDvMkNIukmUJQ52P7SHWDza3s6U67 @router";
  vm-nessus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhR7yuLON8nAsW8SfvwQ2yq5guhu6BPGOR9zfhu6wf+ @nessus";
in
{

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Router                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/router/.caddy/acme.env.age".publicKeys = [ audea vm-router ];
  "systems/x86_64-linux/router/.wireguard/key.age".publicKeys = [ audea vm-router ];
  "systems/x86_64-linux/router/.wireguard/profiles.conf.age".publicKeys = [ audea ];

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃              RedTeam: Nessus              ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/redteam/02.nessus/.nessus/env.age".publicKeys = [ audea vm-nessus ];
}
