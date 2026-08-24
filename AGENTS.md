# AGENTS.md — Nix Configuration (Dendritic Pattern)

This repository is Infrastructure as Code (IaC) using Nix. It manages workstations (desktops) and servers. Configuration lives in `dendritic/` and is auto-imported by `flake.nix` via `flake-parts` and `import-tree`.

---

## ⚖️ Contributing Rules

Before making any change, **read [CONTRIBUTING.md](CONTRIBUTING.md) fully** — it is mandatory reading for every human and AI agent. It defines the rules you must follow:

- Never work or commit directly on `main` — every change goes on a dedicated `type/short-description` branch (e.g. `feat/x`, `fix/y`, `chore/z`).
- Never merge without explicit consent from the project lead; merges use `--no-ff`.
- Every commit follows **Conventional Commits** with a **mandatory scope** (`type(scope): imperative description`).
- Never append `Co-Authored-By:` trailers to commit messages.
- All checks must pass before any change is complete.

When in doubt about the git workflow, defer to `CONTRIBUTING.md` over anything in this file.

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

| Directory   | Scope                                       | Platform             |
|-------------|----------------------------------------------|----------------------|
| `boot/`     | Boot loaders, EFI, kernel params              | NixOS                |
| `cpu/`      | CPU microcode, governors                      | NixOS                |
| `disko/`    | Disk partitioning layouts                     | NixOS                |
| `fonts/`    | Font packages                                 | All platforms        |
| `gpu/`      | GPU drivers                                   | NixOS                |
| `hardware/` | Kernel modules, hardware support              | NixOS                |
| `meta/`     | Bundles that import a set of `software-*` modules together | All platforms |
| `network/`  | DNS, firewall, interfaces                     | NixOS                |
| `profile/`  | Personal identity: git signature, SSH keys, secrets (`age.secrets`) | Home Manager |
| `rice/`     | Desktop structure/behaviour presets (keybinds, launchers, session) — theme-agnostic | NixOS / Home Manager |
| `service/`  | System-level services (sshd hardening, etc.)  | NixOS / Darwin       |
| `settings/` | Global defaults (locale, nix, nixpkgs)        | All platforms        |
| `software/` | Packages and user-level tools                 | All platforms        |
| `system/`   | Composed system-level presets                 | NixOS                |
| `themes/`   | Per-theme palettes/wallpapers that self-configure whichever supported software is detected on the host | Home Manager |

> **`service/` vs `software/` for the same program** (e.g. SSH): `service/` holds the
> system-facing side — the daemon, its hardening, firewall exposure (`service-ssh` configures
> and hardens `sshd`). `software/` holds the user-facing side — client config and CLI tooling
> (`software-ssh` configures the SSH *client*: `~/.ssh/config`, agent, `sshpass`). If a program
> has both a service and a client story, expect two modules, one per category, not one module
> straddling both.

> **`profile/` holds identity, not tooling.** Anything that only makes sense for one specific
> person — a Git name/email, a private SSH key, an `age` secret — belongs in a `profile-*`
> module, never inside a `software-*`/`meta-*` module. `software-*` modules must stay reusable
> by any user on any host; if a module needs to reference "the" SSH identity for a host,
> compose it by importing the right `profile-*` module instead of inlining the value.

> **`themes/` self-detects, it is never imported by the software it themes.** A `themes-*`
> module (e.g. `themes-osakajade`) is a standalone leaf: hosts import it directly, and it
> reads `config` to decide what to theme — `lib.mkIf (config.wayland.windowManager.hyprland.enable
> or false) { ... }` for Hyprland, and so on per supported program — instead of declaring
> `imports = [software-hyprland]` and assuming that program is present. This is the same
> "detect through config, never an unconditional import" rule from *No custom options; derive
> from imports* below, applied to theming: a host without Hyprland gets no Hyprland config from
> the theme, silently, rather than an eval error or a forced dependency. Assets a theme needs
> (palette, wallpapers) are vendored alongside its `default.nix`, pinned to a specific upstream
> version — never read from a live path outside the repo (e.g. a scratch clone under `/tmp`).

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

**This only applies to *additive* lists** — keys another module or a host may plausibly want to
extend rather than replace wholesale (`home.packages`, `environment.systemPackages`,
`homebrew.brews`, container `devices`/`ports`/`volumes`, shell integration `flags`/`options`).
For those, `mkDefault` is wrong because a host adding an item at normal priority would wipe out
the module's items instead of appending to them.

It does **not** apply to *single-owner* lists — a list-valued option that only one module ever
sets, where a host overriding it means "replace this wholesale," not "add to it": DNS
`nameservers`/`search` (`network-dns`), disk `mountOptions`/`extraArgs` (`disko-*`), the sshd
`ports` list (`service-ssh`). There, `lib.mkDefault` is correct and desired — it lets a host swap
the whole list without `lib.mkForce`, exactly like a scalar. Judge each list on "could a second
module reasonably want to add to this same key," not on whether it's syntactically a list.

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

### No custom options; derive from imports

Do **not** declare `options.my.*` knobs. Modules set sensible defaults directly with `lib.mkDefault` (scalars) or plain values (lists/attrsets, which merge with `concatLists`). Hosts tune behaviour by setting the underlying option directly in their host file.

```nix
flake.nixosModules.software-ollama = {config, pkgs, ...}: {
  services.ollama = {
    enable = lib.mkDefault true;
    package = lib.mkDefault (
      if builtins.elem "nvidia" (config.boot.initrd.kernelModules or [])
      then pkgs.ollama-cuda
      else pkgs.ollama
    );
  };
};
```

When a module's behaviour depends on another module (e.g. pick a GPU backend because `gpu-nvidia` was imported), detect it through the config the other module sets — never through a custom option or an unconditional import. The `or false` / `?` existence guards make the check robust when the module is absent.

```nix
# host that imported gpu-nvidia:
services.ollama.package = pkgs.ollama-cuda;
```

### Dependencies between modules

When a module depends on another, import it explicitly at the top and keep the config out of the host's hands:

```nix
homeManagerModules.software-claude = { inputs, ... }: {
  imports = with inputs.self.homeManagerModules; [software-mcp];
};
```

### Never hardcode usernames, home paths or machine-specific values

Modules are shared across hosts and users. A literal like `/home/wizard/...`
or `USERNAME = "wizard"` inside a module breaks every other host and leaks a
personal value into reusable code. Derive user-specific values from the
configuration instead — e.g. discover the primary interactive user through
`config.users.users` and fall back to a generic state directory when none can
be determined:

```nix
nixosModules.software-windows = {config, lib, ...}: let
  normalUsers = lib.attrNames
    (lib.filterAttrs (_: user: user.isNormalUser or false) config.users.users);
  primaryUser = lib.head (normalUsers ++ [null]);
  sharedDir =
    if primaryUser == null then "/var/lib/windows"
    else "/home/${primaryUser}/Windows";
in {
  # volumes = lib.mkDefault [ "${sharedDir}:/data" ];
};
```

If a value truly cannot be derived, it is machine-specific: move it to the
host file, where per-host values belong.

### Reference executables by store path in generated config

When a module generates scripts, keybinds or launchers that invoke external
programs, interpolate the store path (`${pkgs.foo}/bin/foo`) instead of a bare
name. The reference puts the binary in the closure, so the shortcut can never
point at a missing program or at whichever version happens to be on `$PATH`.
Pure dispatchers that run no external command need nothing.

---

## Host Files

A host file in `dendritic/hosts/` should contain:

1. A list of `imports` covering all required behaviour.
2. Machine-specific values that cannot be abstracted (disk device path, hostname, initial password, static IPs, per-host `homebrew` additions).

**Nothing else.** If you find programs, services, fonts, or user definitions declared inline in a host file, those are candidates for new modules. Imports inside a host should be kept sorted using the `keep-sorted` tool's start/end marker comments.

---

## Workflow

Follow the branch and commit conventions in [CONTRIBUTING.md](CONTRIBUTING.md). Before committing any changes, always run in order:

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
