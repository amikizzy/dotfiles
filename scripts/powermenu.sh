#!/usr/bin/env bash
set -euo pipefail

prompt="$(hostname)"
mesg="Uptime: $(uptime -p | sed 's/up //')"

option_1=" Lock"
option_2="󰍃 Logout"
option_3=" Suspend"
option_4=" Reboot"
option_5=" Shutdown"

rofi_menu() {
  echo -e "${option_1}\n${option_2}\n${option_3}\n${option_4}\n${option_5}" | rofi \
    -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -theme-str 'window {width: 400px; height: 300px;}' \
    -theme-str 'inputbar {enabled: false;}' \
    -markup-rows
}

confirm() {
  echo -e " Yes\n No" | rofi \
    -dmenu \
    -p 'Confirm' \
    -theme-str 'window {width: 350px; height: 200px;}' \
    -theme-str 'inputbar {enabled: false;}'
}

run_lock() {
  if command -v hyprlock >/dev/null 2>&1; then
    hyprlock
  else
    notify-send 'Lock' 'hyprlock not found'
  fi
}

run_logout() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exit
  else
    notify-send 'Logout' 'hyprctl not found'
  fi
}

run_suspend() {
  systemctl suspend
}

run_reboot() {
  systemctl reboot
}

run_shutdown() {
  systemctl poweroff
}

choice="$(rofi_menu)"
case "$choice" in
  "$option_1") run_lock ;;
  "$option_2") if [ "$(confirm)" = " Yes" ]; then run_logout; fi ;;
  "$option_3") if [ "$(confirm)" = " Yes" ]; then run_suspend; fi ;;
  "$option_4") if [ "$(confirm)" = " Yes" ]; then run_reboot; fi ;;
  "$option_5") if [ "$(confirm)" = " Yes" ]; then run_shutdown; fi ;;
  *) exit 0 ;;

esac
