# Contributing to this repo

> This document is addressed to **every person who touches this codebase** — human
> or AI agent. Read it fully before making any change. There are no exceptions.

---

## The golden rules

These rules are non-negotiable. Violating any of them will require the
work to be redone from scratch.

### 1. You never work on `main`

`main` is the stable, deployable trunk. It is not a scratch pad.

- **Never commit directly to `main`.**
- **Never push to `main` directly.**
- **Every single change**, no matter how small — a typo fix, a one-line tweak,
  a module bump — goes on a dedicated branch first.

If you find yourself on `main` with uncommitted changes, stop. Stash them,
create a branch, and apply them there:

```bash
git stash
git checkout -b fix/my-accidental-change
git stash pop
```

### 2. You never merge without explicit consent

Merging into `main` is a deliberate, human-approved action. No branch is ever
merged automatically, speculatively, or "just to keep things tidy".

- **Wait for an explicit "merge this" instruction** before running any merge.
- When in doubt, ask. Do not assume.
- The only person who authorises a merge is the project lead.

When a merge is authorised, always use `--no-ff` so the branch topology is
preserved in the graph:

```bash
git checkout main
git merge --no-ff feat/my-feature -m "Merge branch 'feat/my-feature' into main"
```

### 3. Every commit and every branch must follow the naming convention

Consistency in naming makes the history readable at a glance. Deviating from
the convention makes the history noisy and harder to audit.

See the [Branch naming](#branch-naming) and [Commit messages](#commit-messages)
sections below for the full rules.

### 4. All checks must pass before any merge — no exceptions

Before even asking for a merge, **every available check must be green**.
This is not optional. A branch that does not pass all checks is not ready to
merge, period.

Run the full suite locally and fix everything before requesting the merge:

```bash
# Format all Nix files (alejandra, deadnix, statix)
nix fmt -- .

# Validate the flake — all outputs must evaluate without errors
nix flake check
```

If **any** of these commands exits with a non-zero code, the branch is not
mergeable. Fix the issues, commit the fixes on the same branch, and re-run
until everything is clean.

---

## Repository structure

This is an **Infrastructure as Code** repository built with Nix, using the
**Dendritic Pattern** — a modular, branching organisation managed by
`flake-parts` and `import-tree`.

```
.
├── flake.nix                  # Entry point — loads everything under dendritic/
├── dendritic/
│   ├── default.nix            # Flake-parts root
│   ├── factory/               # Host factory helpers
│   ├── hosts/
│   │   ├── desktop/
│   │   │   ├── x86_64-linux/
│   │   │   │   ├── antiquary.nix   # NixOS gaming/desktop
│   │   │   │   └── wonderland.nix  # NixOS desktop
│   │   │   └── x86_64-darwin/      # macOS workstations
│   │   └── homelab/
│   │       ├── automation/
│   │       ├── gaming/
│   │       ├── media/
│   │       ├── proxy/
│   │       └── router/
│   └── modules/
│       ├── boot/              # Bootloader configs
│       ├── cpu/               # CPU-specific tuning
│       ├── disko/             # Disk partitioning layouts
│       ├── gpu/               # GPU drivers and settings
│       ├── hardware/          # Generic hardware modules
│       ├── network/           # Networking (NM, firewall, etc.)
│       ├── rice/
│       │   └── antiquary/     # Hyprland desktop theme + dotfiles
│       ├── service/           # System services (homelab)
│       ├── settings/          # Cross-cutting settings (wayland, etc.)
│       ├── software/          # Per-app modules (bat, git, hyprland, …)
│       └── system/            # Core system configuration
```

Every `.nix` file under `dendritic/` is **automatically discovered** by
`import-tree`. If you create a new file, **add it to git** (`git add`) before
running `nix flake check`, otherwise Nix will not see it:

```bash
git add dendritic/modules/software/myapp.nix
nix flake check
```

---

## Module anatomy

Every module lives in `dendritic/modules/<category>/<name>.nix` and **must**
follow the Dendritic Pattern. A module exposes its configuration via
`flake.homeManagerModules`, `flake.darwinModules`, and/or `flake.nixosModules`.

Only include the attribute if it contains actual configuration — no empty
placeholders.

```nix
# dendritic/modules/software/myapp.nix
{ lib, ... }: {
  flake = {
    # User-level config (dotfiles, CLI tools)
    homeManagerModules.software-myapp = { pkgs, ... }: {
      home.packages = with pkgs; [ myapp ];
    };

    # macOS system-level config
    darwinModules.software-myapp = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ myapp ];
    };

    # NixOS system-level config
    nixosModules.software-myapp = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ myapp ];
    };
  };
}
```

### Executable references

When referencing executables inside Nix strings (e.g. in Hyprland `exec-once`,
`bind`, or any shell command), **always use the full nix store path**. Never
rely on `$PATH`:

```nix
# ✗ Wrong — assumes the binary is in $PATH at runtime
"exec-once = nm-applet"

# ✓ Correct — path is resolved at build time, reproducible
"${pkgs.networkmanagerapplet}/bin/nm-applet"
```

This applies to subshell invocations too:

```nix
# ✓ Every binary in the subshell must also be fully qualified
"${pkgs.quickshell}/bin/quickshell ipc call foo_$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '...')"
```

---

## Branch naming

Branches follow the `type/short-description` pattern in **kebab-case**:

```
feat/hyprland-workspace-cycling
fix/antiquary-exec-once-paths
chore/bump-nixpkgs
docs/contributing
refactor/rice-antiquary-split
```

| Prefix | When to use |
|--------|-------------|
| `feat/` | New feature or capability |
| `fix/` | Bug fix |
| `chore/` | Maintenance — inputs, tooling, cleanup |
| `docs/` | Documentation only |
| `refactor/` | Restructure without behaviour change |
| `style/` | Formatting, whitespace |
| `perf/` | Performance improvement |

**Rules:**
- Use only lowercase letters, numbers and hyphens. No slashes beyond the prefix.
- Keep descriptions short and specific (`fix/kitty-float-rule` not `fix/stuff`).
- One concern per branch. If you need to do two unrelated things, open two branches.

---

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/) **strictly**.
Every commit must have the format:

```
type(scope): short imperative description

Optional body explaining *why*, not *what*.
```

**The scope is mandatory. Never omit it.**

The description must be in the **imperative mood** ("add", "fix", "remove" — not
"added", "fixes", "removing").

### Types

| Type | When to use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `chore` | Maintenance (inputs, tooling, config) |
| `docs` | Documentation only |
| `refactor` | Code restructure without behaviour change |
| `style` | Formatting, whitespace |
| `perf` | Performance improvement |

### Valid examples

```
feat(hyprland): add M+arrows for window focus navigation
fix(antiquary): use full nix store paths in exec-once
chore(inputs): bump nixpkgs to nixos-unstable 2026-07
docs(contributing): adapt guide to nix iac repo
refactor(rice): extract hyprshot into standalone module
```

### Invalid examples — do not do this

```
fix stuff                          ← missing type and scope
feat(hyprland): Added new binding  ← past tense, should be "add"
update                             ← meaningless, no type, no scope
WIP                                ← never commit WIP to a shared branch
feat(rice): fix bindings and bump inputs and refactor module  ← three concerns
```

### Merge commits

Merge commits also follow the convention. The message is generated when
you use the `--no-ff` flag with `-m`:

```bash
git merge --no-ff feat/hyprland-bindings -m "Merge branch 'feat/hyprland-bindings' into main"
```

---

## Workflow summary

```
1.  Start from an up-to-date main
    git checkout main && git pull

2.  Create a branch
    git checkout -b feat/my-feature

3.  Make changes following the module anatomy rules

4.  Stage any new files so Nix can discover them
    git add dendritic/modules/...

5.  Run all checks — fix until green
    nix fmt -- . && nix flake check

6.  Commit with a conventional message
    git commit -m "feat(scope): do something specific"

7.  Push the branch (never main) and ask for a merge
    git push origin feat/my-feature
```

That's it. No shortcuts.
