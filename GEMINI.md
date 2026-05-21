# Workflow Guide - Nix Configuration (Dendritic Pattern)

This repository contains my Infrastructure as Code (IaC) using Nix, managing both workstations (desktops) and servers.

## Architecture: Dendritic Pattern

We use the **Dendritic Pattern** to organize the configuration in a modular and branching way. The core logic resides in the `dendritic/` directory and is dynamically loaded in `flake.nix` using `flake-parts` and `import-tree`.

### Module Structure

Every module defined within `dendritic/modules/` must be as versatile as possible. The goal is for a single file to be capable of configuring different environments.

When creating or modifying a module, you should aim to cover the following whenever possible, but **only include the attribute if it contains actual configuration** (avoid empty placeholders):
1.  **Home Manager**: User-level configurations (dotfiles, CLI tools).
2.  **nix-darwin**: Specific configurations for macOS.
3.  **NixOS**: System-level configurations for NixOS (Linux servers and desktops).

#### Module Structure Example (`bat.nix`):
```nix
{ lib, ... }: {
  flake = {
    darwinModules.bat-software = { /* ... */ };
    homeManagerModules.bat-software = { /* ... */ };
    nixosModules.bat-software = { /* ... */ };
  };
}
```

## Workflow and Standards

To maintain the integrity and consistency of the repository, it is mandatory to follow these steps before finalizing any changes:

1.  **Formatting**: Run the formatter to ensure the code follows project standards (managed by `treefmt` with `alejandra`, `deadnix`, `statix`, etc.).
    ```bash
    nix fmt -- .
    ```

2.  **Validation**: Ensure the flake is valid and passes all consistency checks.
    ```bash
    nix flake check
    ```

## Host Types

-   **Desktops**: Personal workstations (macOS or NixOS).
-   **Servers/Homelab**: Automation, media, proxy, router servers, etc. (NixOS).

---

*Note: This file serves as the fundamental guide for Gemini/Claude when interacting with this repository. Always respect the dendritic pattern and cross-platform compatibility in modules.*
