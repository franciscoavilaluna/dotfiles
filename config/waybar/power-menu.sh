#!/usr/bin/env bash
choice=$(powerprofilesctl list \
    | awk '/^[ *] [a-z-]+:/{gsub(/[*:]/,""); print $1}' \
    | fuzzel --dmenu --prompt "power> ")

[ -n "$choice" ] && powerprofilesctl set "$choice"
