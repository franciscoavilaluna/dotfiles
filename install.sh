#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/franciscoavilaluna/dotfiles.git"
DEST="$HOME/.dotfiles"
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
    brightnessctl
    ttf-jetbrains-mono
    qt5-wayland
    qt6-wayland
    git
    base-devel
)

command -v pacman >/dev/null || { echo "Script made EXCLUSIVELY for Arch btw (pacman)."; exit 1; }
[ "$EUID" -ne 0 ] || { echo "Don't run as root, use your user."; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -d "$SCRIPT_DIR/config" ]; then
    if [ "${DOTFILES_BOOTSTRAPPED:-}" = "1" ]; then
        echo "Error: config/ folder not found in $SCRIPT_DIR. Is the repo layout correct?"
        exit 1
    fi
    echo "==> Downloading dotfiles in $DEST"
    sudo pacman -Sy --needed --noconfirm git
    if [ -d "$DEST/.git" ]; then
        git -C "$DEST" pull --ff-only
    else
        git clone "$REPO_URL" "$DEST"
    fi
    exec env DOTFILES_BOOTSTRAPPED=1 bash "$DEST/install.sh"
fi
REPO="$SCRIPT_DIR"

echo "==> Updating system"
sudo pacman -Syu --noconfirm

echo "==> Switching to PipeWire"
if pacman -Qq pulseaudio &>/dev/null; then
    echo "  PulseAudio detected, replacing it"
    systemctl --user disable --now pulseaudio.service pulseaudio.socket 2>/dev/null || true
fi
sudo pacman -S --needed --noconfirm --ask=4 pipewire pipewire-pulse pipewire-alsa wireplumber

echo "==> Installing packages"
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "==> Linking configs"
mkdir -p "$CONFIG"
shopt -s nullglob
dirs=("$REPO"/config/*/)
if [ "${#dirs[@]}" -eq 0 ]; then
    echo "Error: no config folders found in $REPO/config"
    exit 1
fi
for src in "${dirs[@]}"; do
    name="$(basename "$src")"
    dest="$CONFIG/$name"

    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        echo "  ok     $name (already linked)"
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

echo "==> Enabling audio services"
systemctl --user enable --now pipewire pipewire-pulse wireplumber || true

echo
echo "Done. Log out, go to a TTY and run: Hyprland"
if [ -d "$BACKUP" ]; then
    echo "Previous configs backed up in: $BACKUP"
fi
