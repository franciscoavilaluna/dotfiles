#!/bin/sh

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=dwm
export XDG_SESSION_DESKTOP=dwm
export DESKTOP_SESSION=dwm
export GDK_BACKEND=x11

#xrandr --output eDP-1 --brightness 1.0 &
feh  --bg-scale ~/.config/images/wallpapers/reinassance.jpg &
picom --config ~/.config/picom/picom.conf &
dwmblocks &
dunst &
setxkbmap -layout "us,latam" -option "grp:alt_space_toggle" &
flameshot &
exec dwm
