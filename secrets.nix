let
  audea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9Dt0O0OJokuV6x1jcejmHvJiGT8ZEubd5/aHGYEyUi audea";
  vm-router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMH4o2Q4cwq9GvJ2+MgErC5Odtf+WPbvz3H7KbOyOhoA @router";
  allPublicKeys = [ audea vm-router ];
in
{

  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Router                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/router/tailscale-preauth.key.age".publicKeys = allPublicKeys;
}
