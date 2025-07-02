#!/bin/bash

# Root-only check
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

echo "Starting root cleanup..."

# 1. Empty root trash
echo "[+] Clearing root trash..."
rm -rf /root/.local/share/Trash/*

# 2. Remove orphan packages
echo "[+] Removing orphan packages..."
pacman -Qdtq &>/dev/null && pacman -Rns --noconfirm $(pacman -Qdtq) || echo "No orphan packages."

# 3. Clean pacman cache (keep last 2 versions)
echo "[+] Cleaning pacman cache..."
paccache -rk0

# 4. Clean yay cache if yay exists
if command -v yay &>/dev/null; then
    echo "[+] Cleaning yay cache..."
    yes | yay -Sc
fi

# 5. Prune Docker if installed
if command -v docker &>/dev/null; then
    echo "[+] Pruning Docker system..."
    docker system prune -a --volumes -f
fi

# 6. Remove unused flatpak runtimes
if command -v flatpak &>/dev/null; then
    echo "[+] Removing unused Flatpak runtimes..."
    flatpak uninstall --unused -y
fi

echo "Cleanup complete!"
