#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

PACKAGES=(
    hyprland
    hyprpaper
    xdg-desktop-portal-hyprland
    polkit
    kitty
    waybar
    fuzzel
    grim
    slurp
    wl-clipboard
    pipewire
    pipewire-pulse
    wireplumber
    brightnessctl
    ttf-jetbrains-mono
    qt5-wayland
    qt6-wayland
    git
    base-devel
)

command -v pacman >/dev/null || { echo "Script made EXCLUSIVELY for Arch btw (pacman)."; exit 1; }
[ "$EUID" -ne 0 ] || { echo "Don't run as root, Use your user."; exit 1; }

echo "==> Insalling packages"
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "==> Linking configs"
mkdir -p "$CONFIG"
for src in "$REPO"/config/*/; do
    name="$(basename "$src")"
    dest="$CONFIG/$name"

    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        echo "  ok     $name (linked)"
        continue
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP"
        mv "$dest" "$BACKUP/$name"
        echo "  backup $name -> $BACKUP/"
    fi

    ln -s "${src%/}" "$dest"
    echo "  link   $name"
done

echo "==> Setting up audio"
systemctl --user enable --now pipewire pipewire-pulse wireplumber || true

echo
echo "Done."
[ -d "$BACKUP" ] && echo "Backed up configs on: $BACKUP"
