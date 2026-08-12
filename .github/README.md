<div align="center">
<img src="logo.png" alt="nix" />
<br/><br/>

[![Built with Nix](https://img.shields.io/badge/Built%20with-Nix%20Flakes-5277C3?style=for-the-badge&logo=nixos&logoColor=white&labelColor=5e81ac&color=d8dee9)](https://nixos.org/)
[![DeepWiki](https://img.shields.io/badge/DeepWiki-Explained%20Repo-4F4FFF?style=for-the-badge&logo=wikibooks&logoColor=white&labelColor=5e81ac&color=d8dee9)](https://deepwiki.com/CosasDePuma/nix)

</div>

## ✨ About This Repo

Personal Infrastructure as Code (IaC) using [Nix](https://nixos.org/) [Flakes](https://nixos.wiki/wiki/Flakes). It manages my desktops (macOS via nix-darwin + Home Manager) and servers (NixOS) from a single, reproducible flake.

## 🦄 Why Nix?

- No more "it works on my machine" problems.
- Effortless rollbacks and upgrades.
- Clean and isolated environments.

## 🧬 Architecture: the Dendritic Pattern

Configuration lives in `dendritic/` and is auto-imported by `flake.nix` via `flake-parts` and `import-tree`. If you need something, you import its module and it works out of the box.

```text
dendritic/
├── hosts/                  # machine-specific values (hostname, user, disk)
│   └── desktop/aarch64-darwin/airbender/
└── modules/                # self-contained, reusable modules
    ├── boot/  cpu/  disko/  gpu/  hardware/  network/  service/
    ├── settings/           # global defaults (locale, nix, nixpkgs)
    ├── software/           # packages & user tools
    ├── meta/               # metapaquetes (meta-terminal, meta-ai)
    ├── profile/            # user profiles (cosasdepuma)
    └── system/             # composed system presets
```

Each module exports its config for the platforms it applies to — **NixOS**, **Home Manager**, and **nix-darwin** — and hosts just import what they need. Secrets are managed with [agenix](https://github.com/ryantm/agenix) (`secrets.nix` + `.age` files).

## 💡 Get Started

```sh
# -- bootstrap a new workspace from the flake template
nix flake init -t github:cosasdepuma/nix#workspace

# -- enter the nix development environment
nix develop

# -- format & validate
nix fmt -- .
nix flake check
```

## 🧩 What's inside?

```text
├───checks                 # per-system checks (treefmt)
├───darwinConfigurations
│   └───airbender          # nix-darwin + Home Manager (aarch64-darwin)
├───darwinModules          # auto-imported nix-darwin modules
├───devShells
│   ├───default            # nix development environment
│   └───nixos              # nixos-rebuild / nh development environment
├───formatter              # treefmt (alejandra, deadnix, statix, keep-sorted)
├───homeManagerModules     # auto-imported Home Manager modules
├───nixosModules           # auto-imported NixOS modules
└───templates
    └───workspace          # Flake template for a new workspace
```

## 🤝 Contributing

Read [CONTRIBUTING.md](../CONTRIBUTING.md) before making any change — it applies to every human and AI agent that touches this repo.

---

<div align="center">

### 🐧 Happy Nix hacking! ❄️

</div>
