#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

shopt -s nullglob
dirs=("$REPO"/config/*/)
backups=("$HOME"/.config-backup-*/)

restore_from_backup() {
    local name="$1" i b
    for ((i = ${#backups[@]} - 1; i >= 0; i--)); do
        b="${backups[i]%/}"
        if [ -e "$b/$name" ]; then
            mv "$b/$name" "$CONFIG/$name"
            echo "  restored $name from $b"
            return
        fi
    done
}

if [ "${#dirs[@]}" -eq 0 ]; then
    echo "Error: no config folders found in $REPO/config"
    exit 1
fi

for src in "${dirs[@]}"; do
    name="$(basename "$src")"
    dest="$CONFIG/$name"

    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        rm "$dest"
        echo "  removed $name"
        restore_from_backup "$name"
    fi
done

echo "Done. Packages and the repo itself were left untouched."
