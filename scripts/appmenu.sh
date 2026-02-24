#!/usr/bin/env bash
set -euo pipefail

options=(
  "  Terminal"
  "  Browser"
  "  VSCodium"
  "  GitHub"
  "  YouTube"
  "  Sober"
)

if command -v wofi >/dev/null 2>&1; then
  choice=$(printf '%s
' "${options[@]}" | wofi --show dmenu --prompt "Apps")
else
  choice=$(printf '%s
' "${options[@]}" | rofi -dmenu -p "Apps" -theme-str 'window {width: 420px;}' -theme-str 'inputbar {enabled: false;}')
fi

case "$choice" in
  *Terminal*) ghostty & ;;
  *Browser*) firefox & ;;
  *VSCodium*) codium & ;;
  *GitHub*) xdg-open https://github.com & ;;
  *Sober*) sober & ;;
  *YouTube*) xdg-open https://youtube.com & ;;
  *) exit 0 ;;
esac
