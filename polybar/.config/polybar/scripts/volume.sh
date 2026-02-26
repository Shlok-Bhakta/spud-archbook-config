#!/usr/bin/env bash
# Volume module for polybar — uses pamixer (pulseaudio/pipewire)

MUTED=$(pamixer --get-mute 2>/dev/null)
VOL=$(pamixer --get-volume 2>/dev/null)

if [ "$MUTED" = "true" ]; then
    echo "󰝟  muted"
elif [ -z "$VOL" ]; then
    echo "󰝟  --"
elif [ "$VOL" -le 33 ]; then
    echo "󰕿  ${VOL}%"
elif [ "$VOL" -le 66 ]; then
    echo "󰖀  ${VOL}%"
else
    echo "󰕾  ${VOL}%"
fi
