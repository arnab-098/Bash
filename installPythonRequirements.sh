#!/bin/bash
# install-requirements.sh
# Installs Python requirements on Arch:
#  - First tries pacman (system package)
#  - Falls back to pip inside a venv if not available

set -e

REQ_FILE="requirements.txt"
VENV_DIR="venv"

if [[ ! -f "$REQ_FILE" ]]; then
    echo "[+] $REQ_FILE not found in current directory!"
    exit 1
fi

# Ensure pacman + python + pip + venv are installed
sudo pacman -S --needed --noconfirm python python-pip python-virtualenv base-devel || true

# Create virtualenv if missing
if [[ ! -d "$VENV_DIR" ]]; then
    echo "[+] Creating virtual environment in $VENV_DIR"
    python -m venv "$VENV_DIR"
fi

# Activate venv
source "$VENV_DIR/bin/activate"

# Process each requirement
while read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue # skip empty lines & comments

    base_pkg=$(echo "$pkg" | sed 's/[<>=!].*//') # strip version specifiers
    arch_pkg="python-${base_pkg,,}"              # lowercase

    echo "[+] Trying to install $pkg as $arch_pkg"

    if sudo pacman -Si "$arch_pkg" &>/dev/null; then
        echo "[+] Found in pacman, installing $arch_pkg"
        sudo pacman -S --needed --noconfirm "$arch_pkg"
    else
        echo "[+] Not in pacman, installing with pip in venv"
        pip install "$pkg"
    fi
done <"$REQ_FILE"

echo "[+] All requirements installed!"
