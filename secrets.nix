let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos";
  vm-router = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMH4o2Q4cwq9GvJ2+MgErC5Odtf+WPbvz3H7KbOyOhoA @router";

  all = [
    nixos
    vm-router
  ];
in
{
  # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  # ┃                   Router                  ┃
  # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  "systems/x86_64-linux/router/wireguard.key.age".publicKeys = [
    nixos
    vm-router
  ];
  "systems/x86_64-linux/router/wireguard-profiles/puma.conf.age".publicKeys = [ nixos ];
}
