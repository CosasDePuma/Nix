# ROADMAP

Pendientes de portar desde el repo de dotfiles (`cosasdepuma/.dotfiles`) a esta config Nix.

## SSH

- [ ] **Claves SSH desde Bitwarden**: `~/.ssh/keys/homelab` y `~/.ssh/keys/pumita` (privadas y públicas) + `~/.ssh/id_ed25519` como symlinks. Requiere secrets (agenix/sops) — el profile `cosasdepuma` ya referencia `IdentityFile ~/.ssh/keys/pumita`.

## Visual

- [ ] **Wallpapers**: gestionar las 6 imágenes de `~/.local/share/wallpapers/` desde Nix.

## Dotfiles

- [ ] **chezmoi.toml**: igualar la config templada de dotfiles (Bitwarden + opciones) en `software-chezmoi`.
