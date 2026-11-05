# dotfiles

Minimal Hyprland setup for Arch Linux: black, keyboard-driven, no clutter.

- **Compositor:** [Hyprland](https://hypr.land) (Lua config, Hyprland 0.55+)
- **Terminal:** [kitty](https://sw.kovidgoyal.net/kitty/), classic retro colors on pure black
- **Bar:** [Waybar](https://github.com/Alexays/Waybar)
- **Launcher:** [fuzzel](https://codeberg.org/dnkl/fuzzel)
- **Wallpaper:** [hyprpaper](https://github.com/hyprwm/hyprpaper)
- **Audio:** PipeWire (replaces PulseAudio if it is installed)

## Install

On a fresh Arch install, as a normal user (not root), with internet access:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/franciscoavilaluna/dotfiles/main/install.sh)
```

Prefer to read the script first? Clone and run it yourself:

```bash
git clone https://github.com/franciscoavilaluna/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install.sh
```

Then log out, switch to a TTY and run `Hyprland`.

> **Note:** the configs are symlinked into `~/.config`, so do not delete the
> cloned folder (`~/.dotfiles` when installed with `curl`).

### What the installer does

1. Updates the system (`pacman -Syu`).
2. Switches audio to PipeWire (removes PulseAudio if present).
3. Installs the packages listed below.
4. Symlinks every folder in `config/` into `~/.config`. Existing configs are
   moved to `~/.config-backup-<timestamp>/`, never overwritten.
5. Enables the PipeWire user services.

Running it again is safe: already-linked configs are skipped.

### Packages

`hyprland`, `hyprpaper`, `xdg-desktop-portal-hyprland`, `polkit`, `kitty`,
`waybar`, `fuzzel`, `grim`, `slurp`, `wl-clipboard`, `brightnessctl`,
`ttf-jetbrains-mono`, `qt5-wayland`, `qt6-wayland`, `git`, `base-devel`,
plus `pipewire`, `pipewire-pulse`, `pipewire-alsa`, `wireplumber`.

All of them come from the official repositories (no AUR needed).

## Uninstall

```bash
cd ~/.dotfiles && ./uninstall.sh
```

Removes the symlinks and restores your previous configs from the newest backup
that contains them. Packages and the repo itself are left untouched.

## Layout

```
.
├── install.sh
├── uninstall.sh
└── config/
    ├── hypr/
    │   ├── hyprland.lua
    │   ├── hyprpaper.conf
    │   └── wallpapers/
    ├── waybar/
    │   ├── config.jsonc
    │   └── style.css
    ├── fuzzel/
    │   └── fuzzel.ini
    └── kitty/
        └── kitty.conf
```

Each folder in `config/` is linked to `~/.config/<name>`. To add another
program, put its config folder inside `config/` and run `./install.sh` again.

## Keybinds

`Super` is the Windows key.

| Keys | Action |
|---|---|
| `Super + Enter` | Open kitty |
| `Super + Space` | App launcher (fuzzel) |
| `Super + Q` | Close window |
| `Super + Shift + Q` | Log out of Hyprland |
| `Super + H/J/K/L` | Focus left / down / up / right |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + Ctrl + H/J/K/L` | Resize window (hold to repeat) |
| `Super + 1-9` | Go to workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + F` | Fullscreen |
| `Super + T` | Toggle tiling / floating |
| `Super + B` | Toggle Waybar |
| `Super + Shift + S` | Screenshot area to clipboard |
| `Alt + Space` | Switch keyboard layout (US / Spanish LatAm) |
| Volume / brightness keys | Volume and screen brightness |

## Customizing

**Wallpaper.** Put images in `config/hypr/wallpapers/` and set the path in
`config/hypr/hyprpaper.conf`:

```ini
wallpaper {
    monitor =
    path = ~/.config/hypr/wallpapers/waves.jpeg
    fit_mode = cover
}
```

Reload with `pkill hyprpaper; hyprpaper &`.

**Keyboard layout.** In `hyprland.lua`, `kb_layout = "us,latam"` and
`kb_options = "grp:alt_space_toggle"`. Use `grp:ctrl_space_toggle` for
Ctrl+Space.

**Natural scrolling.** Set `natural_scroll = true` inside `input` (and
`touchpad`) in `hyprland.lua`.

**Kitty colors.** Edit the colors block in `config/kitty/kitty.conf` and reload
with `Ctrl + Shift + F5`.

**Waybar.** After editing `style.css`, reload with `pkill -SIGUSR2 waybar`.

## Notes

- Arch Linux only (the installer uses `pacman`).
- Hyprland 0.55 moved from `hyprland.conf` to a Lua config. If an option stops
  working after an update, run `hyprctl configerrors` to see what changed.
