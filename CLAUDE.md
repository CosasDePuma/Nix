# Workflow Guide — Nix Configuration (Dendritic Pattern)

This repository contains Infrastructure as Code (IaC) using Nix, managing both workstations (desktops) and servers. Configuration lives in `dendritic/` and is auto-imported by `flake.nix` via `flake-parts` and `import-tree`.

---

## Architecture: Dendritic Pattern

The **Dendritic Pattern** is the fundamental rule of this repo: **if you need something, you import it and it works out-of-the-box**. Every module must be fully self-contained. A host file should ideally be a list of imports plus a handful of machine-specific values (disk device, hostname, initial password). Nothing more.

> If configuration logic appears inline in a host file and could logically be reused elsewhere, it belongs in a module.

---

## Module Structure

All modules live in `dendritic/modules/` under a category subdirectory. Each module file exports its configuration to all applicable platforms inside a `flake = { ... }` block. Only include an attribute if it has actual content — never leave empty placeholders.

```nix
{ lib, ... }: {
  flake = {
    darwinModules.category-name    = { /* macOS config */ };
    homeManagerModules.category-name = { /* user-level config */ };
    nixosModules.category-name     = { /* NixOS system config */ };
  };
}
```

### Categories

| Directory   | Scope                                  | Platform        |
|-------------|----------------------------------------|-----------------|
| `boot/`     | Boot loaders, EFI, kernel params       | NixOS           |
| `cpu/`      | CPU microcode, governors               | NixOS           |
| `disko/`    | Disk partitioning layouts              | NixOS           |
| `gpu/`      | GPU drivers                            | NixOS           |
| `hardware/` | Kernel modules, hardware support       | NixOS           |
| `network/`  | DNS, firewall, interfaces              | NixOS           |
| `services/` | System services (SSH, etc.)            | NixOS / Darwin  |
| `settings/` | Global defaults (locale, nix, nixpkgs) | All platforms   |
| `software/` | Packages and user-level tools          | All platforms   |
| `system/`   | Composed system-level presets          | NixOS           |

---

## Naming Convention

- **File name**: `category-name.nix` (lowercase, hyphen-separated)
- **Export key**: matches the file name, e.g. `software-bat`, `network-firewall`, `services-ssh`
- **Import in host**: `inputs.self.nixosModules.software-bat`

The file name and the export key must match exactly. This is what makes `import-tree` auto-discovery work.

---

## Coding Rules

### Always use `lib.mkDefault`

Every setting in a module must be wrapped in `lib.mkDefault`. This allows hosts to override any default without using `lib.mkForce`, keeping the layering clean.

```nix
programs.bat.config = {
  color  = lib.mkDefault "always";
  paging = lib.mkDefault "never";
};
```

### Cross-platform differences stay inside the module

When the NixOS and HomeManager APIs differ (e.g. `programs.bat.settings` vs `programs.bat.config`), handle the difference inside the module — never expose it to the host.

### HomeManager modules may reference `osConfig`

Use `osConfig` to conditionally activate HomeManager config when the corresponding system program is enabled:

```nix
homeManagerModules.software-foo = { osConfig, lib, ... }: {
  config = lib.mkIf osConfig.programs.foo.enable {
    programs.foo.settings = { /* ... */ };
  };
};
```

### Use `lib.mkMerge` for conditional blocks

When a module has both unconditional and conditional parts, use `lib.mkMerge`:

```nix
config = lib.mkMerge [
  { /* always-on config */ }
  (lib.mkIf condition { /* conditional config */ })
];
```

### Factories for parameterized modules

When a module needs parameters (e.g. a user with a name, home directory, SSH keys), use the factory pattern under `dendritic/factory/`:

```nix
config.flake.factory.my-factory = { name, ... }: { lib, ... }: {
  users.users.${name} = { /* ... */ };
};
```

---

## Host Files

A host file in `dendritic/hosts/` should contain:

1. A list of `imports` covering all required behaviour.
2. Machine-specific values that cannot be abstracted (disk device path, hostname, initial password, static IPs).

**Nothing else.** If you find programs, services, fonts, portal config, or user definitions declared inline in a host file, those are candidates for new modules.

### Current known gaps in `wonderland.nix`

The following inline blocks in `wonderland.nix` should each become their own module:

| Inline config                         | Target module              |
|---------------------------------------|----------------------------|
| `environment.sessionVariables` (Wayland vars) | `settings-wayland`   |
| `environment.systemPackages` (desktop apps)   | `software-niri` (or per-app modules) |
| `fonts.*`                             | `settings-fonts`           |
| `programs.dconf`, `programs.firefox`, `programs.xwayland` | `software-dconf`, `software-firefox`, `software-xwayland` |
| `services.greetd`                     | `services-greetd`          |
| `services.pipewire` + `services.pulseaudio` | `services-pipewire`   |
| `services.xserver` (xkb layout)       | `settings-keyboard`        |
| `xdg.portal.*`                        | `settings-xdg-portal`      |
| `users.users.rabbit`                  | user factory or dedicated module |
| `specialisation.gaming`               | `specialisation-gaming`    |

---

## Workflow

Before committing any changes, always run in order:

```bash
# 1. Format
nix fmt -- .

# 2. Validate
nix flake check
```

Both must pass cleanly.

---

## Host Types

- **Desktops**: Personal workstations (`dendritic/hosts/desktop/`), macOS or NixOS.
- **Homelab servers**: Automation, media, proxy, router, gaming (`dendritic/hosts/homelab/`), always NixOS.
