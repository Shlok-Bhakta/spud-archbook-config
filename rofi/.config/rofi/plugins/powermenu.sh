#!/usr/bin/env bash
# Powermenu using rofi - Catppuccin Mocha

lock="  Lock"
logout="  Logout"
suspend="  Suspend"
reboot="  Reboot"
shutdown="  Shutdown"

chosen=$(printf '%s\n' "$lock" "$logout" "$suspend" "$reboot" "$shutdown" | rofi \
    -dmenu \
    -i \
    -p "  Power" \
    -theme-str 'window { width: 360px; } listview { columns: 1; lines: 5; } inputbar { children: [prompt]; }' \
    -theme "~/.config/rofi/theme.rasi")

case "$chosen" in
    "$lock")     i3lock --color=1e1e2e ;;
    "$logout")   i3-msg exit ;;
    "$suspend")  systemctl suspend ;;
    "$reboot")   systemctl reboot ;;
    "$shutdown") systemctl poweroff ;;
esac
