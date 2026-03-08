#!/usr/bin/env bash

set -u

battery_device=""
while IFS= read -r device; do
  case "$device" in
    *battery_BAT*|*/battery*)
      battery_device="$device"
      break
      ;;
  esac
done < <(upower -e 2>/dev/null)

if [ -z "$battery_device" ]; then
  notify-send "Battery" "Battery details unavailable"
  exit 0
fi

state=""
percentage=""
time_to_empty=""
time_to_full=""

while IFS=: read -r key value; do
  key=$(printf '%s' "$key" | xargs)
  value=$(printf '%s' "$value" | xargs)

  case "$key" in
    state) state="$value" ;;
    percentage) percentage="$value" ;;
    "time to empty") time_to_empty="$value" ;;
    "time to full") time_to_full="$value" ;;
  esac
done < <(upower -i "$battery_device" 2>/dev/null)

message="State: ${state:-unknown}"
if [ -n "$percentage" ]; then
  message="$message\nCharge: $percentage"
fi

if [ "$state" = "discharging" ] && [ -n "$time_to_empty" ]; then
  message="$message\nRemaining: $time_to_empty"
elif [ "$state" = "charging" ] && [ -n "$time_to_full" ]; then
  message="$message\nTo full: $time_to_full"
fi

notify-send "Battery" "$message"
