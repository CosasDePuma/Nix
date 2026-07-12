#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing NixOS Media Server ==="

# Partition and format disk with disko
echo ">>> Partitioning disk..."
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 1MB 2MB
parted /dev/sda -- set 1 bios_grub on
parted /dev/sda -- mkpart primary 2MB 1GB
parted /dev/sda -- mkpart primary 1GB 100%

mkfs.ext4 -F -L BOOT /dev/sda2
mkfs.ext4 -F -L NIXOS /dev/sda3

# Mount filesystems
echo ">>> Mounting filesystems..."
mount -t tmpfs none /mnt
mkdir -p /mnt/{boot,nix,etc/nixos}
mount /dev/sda3 /mnt/nix
mount /dev/sda2 /mnt/boot

# Install git
echo ">>> Installing git..."
nix-env -iA nixos.git

# Clone config
echo ">>> Cloning configuration..."
cd /tmp
git clone https://github.com/CosasDePuma/Nix.git nix-config
cd nix-config

# Install NixOS
echo ">>> Installing NixOS..."
nixos-install --flake .#media --no-root-password

echo ">>> Installation complete! Rebooting in 5 seconds..."
sleep 5
reboot
