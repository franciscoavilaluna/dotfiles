#!/usr/bin/env bash
set -u

SOCK="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
EXT_SCALE=1             # escala del monitor externo
PRIORITY=resolution     # resolution = máx. resolución y luego máx. Hz | refresh = máx. Hz primero
FUZZEL=(fuzzel --dmenu --lines 4)

mons() { hyprctl monitors all -j; }
hl_mon() { hyprctl eval "hl.monitor({ $1 })" >/dev/null; }

ask() { "${FUZZEL[@]}"; }   # opciones por stdin

# Mejor modo disponible del monitor $1 -> "2560x1440@165.00"
best_mode() {
  mons | jq -r --arg n "$1" --arg p "$PRIORITY" '
    .[] | select(.name == $n) | .availableModes
    | map(. as $s
          | capture("^(?<w>[0-9]+)x(?<h>[0-9]+)@(?<r>[0-9.]+)Hz$")
          | {s: $s, px: ((.w|tonumber) * (.h|tonumber)), r: (.r|tonumber)})
    | sort_by(if $p == "refresh" then [.r, .px] else [.px, .r] end)
    | last | .s | sub("Hz$"; "")'
}

handle() {
  local ext=$1 int imode iw ih iscale
  sleep 0.4

  # Pantalla interna: nombre, modo actual, tamaño lógico y escala
  read -r int imode iw ih iscale < <(mons | jq -r '
    [.[] | select(.name | test("^(eDP|LVDS|DSI)"))][0]
    | select(. != null)
    | "\(.name) \(.width)x\(.height)@\(((.refreshRate*100)|round)/100) \((.width/.scale)|round) \((.height/.scale)|round) \(.scale)"')
  [[ -z ${int:-} || $ext == "$int" ]] && return

  # Máximo refresh del externo, aplicado de inmediato (antes del menú)
  local emode res ew eh
  emode=$(best_mode "$ext")
  hl_mon "output = '$ext', mode = '$emode', position = 'auto', scale = $EXT_SCALE, disabled = false"
  res=${emode%@*}
  ew=$(awk -v v="${res%x*}" -v s="$EXT_SCALE" 'BEGIN{printf "%d", v/s}')
  eh=$(awk -v v="${res#*x}" -v s="$EXT_SCALE" 'BEGIN{printf "%d", v/s}')

  local choice
  choice=$(printf '%s\n' "Extender" "Duplicar" "Solo externo" "Solo interno" | ask "Pantalla") || return

  inton()  { hl_mon "output = '$int', mode = '$imode', position = '0x0', scale = $iscale, disabled = false"; }
  extpos() { hl_mon "output = '$ext', mode = '$emode', position = '$1', scale = $EXT_SCALE, disabled = false"; }

  case $choice in
    "Duplicar")
      inton
      hl_mon "output = '$ext', mode = '$emode', position = '0x0', scale = $EXT_SCALE, mirror = '$int', disabled = false" ;;
    "Solo externo")
      extpos 0x0
      hl_mon "output = '$int', disabled = true" ;;
    "Solo interno")
      inton
      hl_mon "output = '$ext', disabled = true" ;;
    "Extender")
      local pos x y
      pos=$(printf '%s\n' "Derecha" "Izquierda" "Arriba" "Abajo" | ask "Posición") || return
      case $pos in
        Derecha)   x=$iw;               y=$(( (ih-eh)/2 )) ;;
        Izquierda) x=$(( -ew ));        y=$(( (ih-eh)/2 )) ;;
        Arriba)    x=$(( (iw-ew)/2 )); y=$(( -eh )) ;;
        Abajo)     x=$(( (iw-ew)/2 )); y=$ih ;;
      esac
      inton
      extpos "${x}x${y}" ;;
  esac
}

# Al desconectar: cierra el menú si seguía abierto y restaura la config base
restore() {
  [[ $1 == eDP* ]] && return
  pkill -x fuzzel
  sleep 0.3
  hyprctl reload >/dev/null
}

socat -u "UNIX-CONNECT:$SOCK" - | while IFS= read -r line; do
  case $line in
    monitoraddedv2">>"*)
      IFS=, read -r _ name _ <<<"${line#*>>}"
      handle "$name" & ;;
    monitorremoved">>"*)
      restore "${line#*>>}" ;;
  esac
done
