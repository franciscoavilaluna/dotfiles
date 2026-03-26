#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="$HOME/.config/dotfiles"

echo -e "${CYAN}>>> STARTING INSTALATION...${NC}"

if ! command -v yay &> /dev/null; then
    echo -e "${CYAN}INSTALLING YAY...${NC}"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm && cd -
fi

echo -e "${CYAN}>>> INSTALLING PACKAGES FROM LIST...${NC}"
yay -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist.txt"

echo -e "${CYAN}>>> COMPILING DWM...${NC}"
for d in "$DOTFILES_DIR/suckless"/*; do
    if [ -d "$d" ] && [ -f "$d/Makefile" ]; then
        echo -e "${GREEN}COMPILING: $(basename "$d")${NC}"
        cd "$d" && sudo make clean install && cd -
    else
        echo -e "${RED}SKIPPING $d (No Makefile)${NC}"
    fi
done

echo -e "${CYAN}>>> CREATING SYMLINKS WITH STOW...${NC}"
cd "$DOTFILES_DIR"

PAQUETES=(system alacritty flameshot images nvim picom statusbar tmux vim zathura)

for pkg in "${PAQUETES[@]}"; do
    if [ -d "$pkg" ]; then
        # -R (Restow), -d . (Current dir), -t ~ (Target HOME)
        stow -R -d . -t ~ "$pkg"
        echo -e "${GREEN}LINKED: $pkg${NC}"
    fi
done

[ -d "$HOME/.local/bin/statusbar" ] && chmod +x $HOME/.local/bin/statusbar/*

echo -e "${GREEN}>>> ¡DONE! RESTART YOUR SYSTEM AND USE 'sx'${NC}"
