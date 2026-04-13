<!--
    Author: Kike Fontán (@CosasDePuma)
    Repository: Nix IaC
    Description: Personal NixOS and nix-darwin flakes configuration managing a multi-system homelab and workstations declaratively, including secrets, services, and network layout.
-->

<div align="center">
<img src="logo.png" alt="nix" />
<br/><br/>

[![Built with Nix](https://img.shields.io/badge/Built%20with-Nix%20Flakes-5277C3?style=for-the-badge&logo=nixos&logoColor=white&labelColor=5e81ac&color=d8dee9)](https://nixos.org/)
[![DeepWiki](https://img.shields.io/badge/DeepWiki-Explained%20Repo-4F4FFF?style=for-the-badge&logo=wikibooks&logoColor=white&labelColor=5e81ac&color=d8dee9)](https://deepwiki.com/CosasDePuma/nix)

</div>

## ✨ About This Repo

This repository contains my personal Infrastructure as Code (IaC) configurations using [Nix](https://nixos.org/) [Flakes](https://nixos.wiki/wiki/Flakes). It helps me manage, reproduce, and share my development environments and system setups with ease.


## 🦄 Why Nix?

- No more "it works on my machine" problems.
- Effortless rollbacks and upgrades.
- Clean and isolated environments.

## 💡 Get Started

```sh
# -- install nix (for non-NixOS systems)
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon

# -- bootstrap a flake structure like this
nix flake init -t github:cosasdepuma/nix#flake

# -- open a nixos development environment
nix develop github:cosasdepuma/nix

# ... and much more!
```

## 🧩 What's inside?

```rb
├───darwinConfigurations
│   └───airbender: Darwin configuration
├───devShells
│   ├───aarch64-darwin
│   │   ├───default: development environment 'nixos'
│       └───hacking-infra: development environment 'hacking-infra'
│   │   └───nixos: development environment 'nixos'
│   └───x86_64-linux
│       ├───default: development environment 'nixos'
│       └───hacking-infra: development environment 'hacking-infra'
│       └───nixos: development environment 'nixos'
├───formatter
│   ├───aarch64-darwin: package 'nixfmt-tree'
│   └───x86_64-linux: package 'nixfmt-tree'
├───nixosConfigurations
│   └───wonderland: NixOS configuration
└───templates
    └───flake: template: Flake template
    └───shell: template: Shell template for development environments
```

---

<div align="center">

### 🐧 Happy Nix hacking! ❄️

</div>