<div align="center">
<img src="logo.png" alt="nix" />
<br/><br/>

[![Built with Nix](https://img.shields.io/badge/Built%20with-Nix%20Flakes-5277C3?style=for-the-badge&logo=nixos&logoColor=white&labelColor=5e81ac&color=d8dee9)](https://nixos.org/)

</div>

## ✨ About This Repo

This repository contains Áudea Infrastructure as Code (IaC) configurations using [Nix](https://nixos.org/) [Flakes](https://nixos.wiki/wiki/Flakes). It helps us manage, reproduce, and share the development environments and system setups with ease.


## 🦄 Why Nix?

- No more "it works on my machine" problems.
- Effortless rollbacks and upgrades.
- Clean and isolated environments.

## 💡 Get Started

```sh
# -- install nix (for non-NixOS systems)
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon

# -- open a nixos development environment
nix develop github:cosasdepuma/nix/audea

# ... and much more!
```

## 🧩 What's inside?

```rb
├───darwinConfigurations: Darwin configuration
├───devShells
│   ├───aarch64-darwin
│   │   ├───default: development environment 'nixos'
│   │   └───nixos: development environment 'nixos'
│   └───x86_64-linux
│       ├───default: development environment 'nixos'
│       └───nixos: development environment 'nixos'
├───formatter
│   ├───aarch64-darwin: package 'nixfmt-tree'
│   └───x86_64-linux: package 'nixfmt-tree'
├───nixosConfigurations
│   └───e-corp: NixOS configuration
└───templates
    └───shell: template: Shell template for development environments
```

---

<div align="center">

### 🐧 Happy Nix hacking! ❄️

</div>