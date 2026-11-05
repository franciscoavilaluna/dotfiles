#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
LATEST_BACKUP="$(ls -dt "$HOME"/.config-backup-* 2>/dev/null | head -n1 || true)"

for src in "$REPO"/config/*/; do
    name="$(basename "$src")"
    dest="$CONFIG/$name"

    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        rm "$dest"
        echo "  removed $name"
        if [ -n "$LATEST_BACKUP" ] && [ -e "$LATEST_BACKUP/$name" ]; then
            mv "$LATEST_BACKUP/$name" "$dest"
            echo "  restored $name from backup"
        fi
    fi
done
