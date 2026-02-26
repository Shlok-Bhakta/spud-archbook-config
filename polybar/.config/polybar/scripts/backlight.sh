#!/usr/bin/env bash
# Backlight module for polybar — reads intel_backlight via brightnessctl
PCT=$(brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/,"",$4); print $4}')
[ -z "$PCT" ] && exit 0

if   [ "$PCT" -ge 67 ]; then ICON="󰃠"
elif [ "$PCT" -ge 34 ]; then ICON="󰃟"
else ICON="󰃞"; fi

echo "${ICON}  ${PCT}%"
