#!/usr/bin/env bash
STATUS=$(playerctl status 2>/dev/null)
if [ "$STATUS" = "Playing" ]; then
    echo "%{F#94e2d5}󰎈%{F-} $(playerctl metadata --format '{{ artist }} - {{ title }}' | cut -c1-40)"
elif [ "$STATUS" = "Paused" ]; then
    echo "%{F#45475a}󰏤%{F-} $(playerctl metadata --format '{{ artist }} - {{ title }}' | cut -c1-40)"
fi
