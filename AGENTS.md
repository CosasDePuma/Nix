# AGENTS.md — Nix Configuration (Dendritic Pattern)

This repository is Infrastructure as Code (IaC) using Nix. It manages workstations (desktops) and servers. Configuration lives in `dendritic/` and is auto-imported by `flake.nix` via `flake-parts` and `import-tree`.

---

## Architecture: Dendritic Pattern

The **Dendritic Pattern** is the fundamental rule of this repo: **if you need something, you import it and it works out-of-the-box**. Every module must be fully self-contained. A host file should ideally be a list of imports plus a handful of machine-specific values (disk device, hostname, initial password). Nothing more.

> If configuration logic appears inline in a host file and could logically be reused elsewhere, it belongs in a module.

---

## Module Structure

All modules live in `dendritic/modules/` under a category subdirectory. Each module file exports its configuration to all applicable platforms inside a `flake = { ... }` block. **Always try to provide the three platform supports — NixOS, Home Manager, and nix-darwin — whenever possible.** Only include an attribute if it has actual content — never leave empty placeholders.

```nix
{lib, ...}: {
  flake = {
    darwinModules.category-name     = { /* macOS config */ };
    homeManagerModules.category-name = { /* user-level config */ };
    nixosModules.category-name      = { /* NixOS system config */ };
  };
}
```

When a platform is not applicable (e.g. a NixOS-only service), simply omit it. Modules may reference `inputs` and `pkgs` in their function arguments when needed.

### Categories

| Directory   | Scope                                  | Platform        |
|-------------|----------------------------------------|-----------------|
| `boot/`     | Boot loaders, EFI, kernel params       | NixOS           |
| `cpu/`      | CPU microcode, governors               | NixOS           |
| `disko/`    | Disk partitioning layouts              | NixOS           |
| `gpu/`      | GPU drivers                            | NixOS           |
| `hardware/` | Kernel modules, hardware support       | NixOS           |
| `network/`  | DNS, firewall, interfaces              | NixOS           |
| `rice/`     | Desktop theming, full rice presets     | NixOS           |
| `service/`  | System services (SSH, etc.)            | NixOS / Darwin  |
| `settings/` | Global defaults (locale, nix, nixpkgs) | All platforms   |
| `software/` | Packages and user-level tools          | All platforms   |
| `system/`   | Composed system-level presets          | NixOS           |

---

## Naming Convention

- **File name**: `category-name.nix` (lowercase, hyphen-separated)
- **Export key**: matches the file name, e.g. `software-bat`, `network-firewall`, `service-ssh`
- **Import in host**: `inputs.self.nixosModules.software-bat` (or `darwinModules` / `homeManagerModules`)

The file name and the export key must match exactly. This is what makes `import-tree` auto-discovery work.

---

## Coding Rules

### Use `lib.mkDefault` for scalars, never for lists

Wrap individual settings in `lib.mkDefault` so hosts can override them without using `lib.mkForce`, keeping the layering clean.

```nix
programs.bat.config = {
  color  = lib.mkDefault "always";
  paging = lib.mkDefault "never";
};
```

**Do not** wrap lists (e.g. `homebrew.brews`, `home.packages`, `environment.systemPackages`) in `lib.mkDefault`. Definitions are filtered by priority: only the highest-priority one survives, so a host that writes the same list key with a normal priority would silently discard the module's whole `mkDefault` list instead of concatenating it. Define lists directly so they always merge with `concatLists`:

```nix
flake.darwinModules.software-foo = {
  homebrew.brews = ["foo"];
};
```

### Cross-platform differences stay inside the module

When the NixOS and HomeManager APIs differ (e.g. `programs.bat.settings` vs `programs.bat.config`, or `programs.zsh.autosuggestions` vs `programs.zsh.autosuggestion`), handle the difference inside the module — never expose it to the host. Each platform gets its own key with the API it expects.

```nix
flake = {
  homeManagerModules.software-bat = { ... }: {
    programs.bat.config = lib.mkDefault batconfig;
  };
  nixosModules.software-bat = { ... }: {
    programs.bat.settings = lib.mkDefault batconfig;
  };
};
```

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

### Custom options inside a module

When a module needs its own knobs (e.g. extending package lists from other modules), declare them with `options.my.<name>` in the same module:

```nix
homeManagerModules.software-vscode = { config, lib, pkgs, ... }: {
  options.my.vscode-extraExtensions = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [];
    description = "Additional VSCode extensions to install.";
  };
  config.programs.vscode = {
    enable = lib.mkDefault true;
    extensions = with pkgs.vscode-extensions; [ ... ] ++ config.my.vscode-extraExtensions;
  };
};
```

### Dependencies between modules

When a module depends on another, import it explicitly at the top and keep the config out of the host's hands:

```nix
homeManagerModules.software-claude = { inputs, ... }: {
  imports = with inputs.self.homeManagerModules; [software-mcp];
};
```

---

## Host Files

A host file in `dendritic/hosts/` should contain:

1. A list of `imports` covering all required behaviour.
2. Machine-specific values that cannot be abstracted (disk device path, hostname, initial password, static IPs, per-host `homebrew` additions).

**Nothing else.** If you find programs, services, fonts, or user definitions declared inline in a host file, those are candidates for new modules. Imports inside a host should be kept sorted using the `keep-sorted` tool's start/end marker comments.

---

## Workflow

Before committing any changes, always run in order:

```bash
# 1. Format
nix fmt -- .

# 2. Validate
nix flake check
```

Both must pass cleanly. The formatter is managed by `treefmt` (`alejandra`, `deadnix`, `statix`, `keep-sorted`).

---

## Host Types

- **Desktops**: Personal workstations (`dendritic/hosts/desktop/`), macOS (`aarch64-darwin`) or NixOS.
- **Servers/Homelab**: Automation, media, proxy, router, gaming (`dendritic/hosts/homelab/`), always NixOS.
