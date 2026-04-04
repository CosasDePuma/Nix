# CLAUDE.md

This file provides guidance when working with code in this repository.

## Overview

Personal NixOS Flakes configuration managing computers and a multi-system homelab. All systems are declaratively defined — no imperative state outside of `secrets.nix` (age-encrypted).

- **Public domain**: kike.wtf
- **Nixpkgs channel**: nixos-unstable
- **State version**: 25.05 (or newer)

## Common Commands

Enter the NixOS management shell first (provides `nh`, `nixfmt-tree`, `statix`, `deadnix`, `agenix`, `nixos-anywhere`):

```bash
nix develop .#nixos   # or just: direnv allow (auto-activates via .envrc)
```

**Rebuild systems:**
```bash
# Local rebuild (wonderland desktop)
nh os switch .

# Remote rebuild (homelab VMs)
nixos-rebuild switch --flake .#router     --target-host router.homelab --build-host router.homelab --no-reexec --sudo
nixos-rebuild switch --flake .#proxy      --target-host proxy.homelab  --build-host proxy.homelab  --no-reexec --sudo
nixos-rebuild switch --flake .#media      --target-host media.homelab  --build-host media.homelab  --no-reexec --sudo
...

# macOS (airbender)
nix run nix-darwin -- switch --flake .#airbender
```

**Format & lint:**
```bash
nix fmt              # format all .nix files with nixfmt-tree
statix check .       # lint for anti-patterns
deadnix .            # find unused bindings
```

**Secrets (agenix):**
```bash
agenix -i ~/.ssh/keys/homelab -e secrets/<name>.age   # edit an encrypted secret
# Keys are declared in secrets.nix with per-host SSH Ed25519 public keys
```

**Fresh install on new machine:**
```bash
nixos-anywhere --flake .#<system> root@<ip>
```

## Repository Structure

```
flake.nix                    # Inputs, all system outputs, devShells, formatter, templates
secrets.nix                  # Age key declarations (maps secrets → allowed host keys)
shells/
  nixos.nix                  # Default devShell: NixOS tooling
  hacking.nix                # Offensive security tools (nmap, metasploit, etc.)
  hacking-infra.nix          # Extended infra pentesting (amass, ffuf, feroxbuster, etc.)
systems/
  aarch64-darwin/airbender/  # Apple Silicon macOS (Homebrew managed via nix-darwin)
  x86_64-linux/desktop/wonderland/   # NVIDIA gaming desktop, Niri/Wayland
  x86_64-linux/homelab/
    router/                  # Gateway: nftables firewall, WireGuard VPN, DDClient DNS
    proxy/                   # Caddy reverse proxy, ACME/Let's Encrypt (*.kike.wtf)
    media/                   # Jellyfin, Radarr, Sonarr, Komga, qBitTorrent + SMB mounts
    automation/              # n8n workflow engine, HandBrake transcoding + SMB mounts
templates/workspace/         # Flake template for new dev environments
```

## Architecture

**Network layout:**
- VLAN10 (homelab): `10.0.10.0/24` — router `.254`, proxy `.1`, media `.3`, automation `.4`
- WireGuard VPN: `10.10.10.0/24`
- TrueNAS NAS: `192.168.1.3` (SMB backend for media and automation)
- SSH on custom port `64022` for all homelab systems

**Secrets flow:** `secrets.nix` maps each `.age` file to the SSH host keys that can decrypt it. Agenix decrypts at activation using the host's `/etc/ssh/ssh_host_ed25519_key`.

**Wonderland desktop specifics:** Uses `niri` Wayland compositor with NVIDIA open drivers (`nvidia_drm.modeset=1`). Has a `gaming` specialisation that adds Steam + Proton + MangoHUD. Display manager is `greetd`+`tuigreet`.

**Proxy/Caddy:** TLS via DNS-01 challenge (Cloudflare API). Wildcard cert for `*.kike.wtf`. Caddyfile lives at `systems/x86_64-linux/homelab/proxy/.caddy/Caddyfile`.

**Router firewall:** nftables rules at `systems/x86_64-linux/homelab/router/.nftables/tables.nft`. Drop-all policy; VLAN10 hosts can only reach the gateway (not each other) except for explicit SMB rules to TrueNAS.

## Key Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | nixos-unstable |
| `nix-darwin` | macOS system config |
| `home-manager` | User-level config (used on darwin) |
| `agenix` | Age-encrypted secrets |
| `disko` | Declarative disk partitioning (used for fresh installs) |
