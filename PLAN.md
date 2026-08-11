# PLAN — Mejoras de módulos

Prioridades según mynixos.com/options. Cada tarea es un módulo a mejorar.

## Alta prioridad

- [x] **`software/ollama.nix`** — deducir backend GPU según módulo importado (`gpu-nvidia` → `ollama-cuda`), sin `options`.
- [x] **`gpu/nvidia.nix`** — añadir `hardware.nvidia.branch` (producción), `videoAcceleration` (VA-API), `forceFullCompositionPipeline` (anti-tearing), `nvidiaPersistenced`.
- [x] **`software/hyprland.nix`** — añadir `programs.hyprland.withUWSM`, `portalPackage`, `xwayland`.
- [x] **`software/qemu.nix`** — añadir `virtualisation.libvirtd.onBoot`/`onShutdown`/`shutdownTimeout`/`parallelShutdown`, `firewallBackend = "nftables"`. (El guard roto de `environment.persistence` se invirtió: ahora `system-impermanence` persiste `/var/lib/libvirt` si libvirtd está habilitado.)

## Media prioridad

- [x] **`software/steam.nix`** — añadir `programs.steam.gamescopeSession`, `remotePlay`, `localNetworkGameTransfers`, `extraCompatPackages`. (Steam Link añadido como masApp en darwin — ID 1246969117; no existe en nixpkgs.)
- [x] **`service/ssh.nix`** — mantener ciphers/MACs (pasan ssh-audit); kex solo post-quantum (`mlkem768x25519-sha256`, `sntrup761x25519-sha512[+@openssh.com]`) eliminando los warns; añadir `PerSourceMaxStartups` (mitigación DHEat).
- [x] **`software/git.nix`** — añadir `programs.git.lfs.enable` y `programs.git.signing` (HM). (Arreglado el gitconfig de NixOS: el `mkDefault` global chocaba con lfs; ahora valores planos que se fusionan. `ignores` no existe en NixOS → `core.excludesFile` + `/etc/gitignore-global`.)
- [ ] **`software/sudo.nix`** — añadir `security.sudo-rs.wheelNeedsPassword` / `extraRules`.

## Baja prioridad

- [ ] **`settings/nix.nix`** — mover `experimental-features` de `extraOptions` a `nix.settings` estructurado.
