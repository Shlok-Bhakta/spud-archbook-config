#!/usr/bin/env bash

set -u

bat_dir=""
for candidate in /sys/class/power_supply/BAT*; do
  if [ -d "$candidate" ]; then
    bat_dir="$candidate"
    break
  fi
done

if [ -z "$bat_dir" ]; then
  notify-send "Battery" "Battery details unavailable"
  exit 0
fi

read_value() {
  local path="$1"
  [ -r "$path" ] && tr -d '\n' < "$path"
}

status=$(read_value "$bat_dir/status")
capacity=$(read_value "$bat_dir/capacity")
status_lc=$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')

energy_now=$(read_value "$bat_dir/energy_now")
energy_full=$(read_value "$bat_dir/energy_full")
power_now=$(read_value "$bat_dir/power_now")

if [ -z "$energy_now" ]; then energy_now=$(read_value "$bat_dir/charge_now"); fi
if [ -z "$energy_full" ]; then energy_full=$(read_value "$bat_dir/charge_full"); fi
if [ -z "$power_now" ]; then power_now=$(read_value "$bat_dir/current_now"); fi

eta=""
if [ -n "$power_now" ] && [ "$power_now" -gt 0 ] 2>/dev/null; then
  if [ "$status_lc" = "discharging" ] && [ -n "$energy_now" ] 2>/dev/null; then
    eta_seconds=$(awk -v e="$energy_now" -v p="$power_now" 'BEGIN { printf "%d", (e/p)*3600 }')
    label="Remaining"
  elif [ "$status_lc" = "charging" ] && [ -n "$energy_now" ] && [ -n "$energy_full" ] 2>/dev/null; then
    eta_seconds=$(awk -v now="$energy_now" -v full="$energy_full" -v p="$power_now" 'BEGIN { rem=full-now; if (rem<0) rem=0; printf "%d", (rem/p)*3600 }')
    label="To full"
  fi

  if [ -n "${eta_seconds:-}" ] && [ "$eta_seconds" -ge 0 ] 2>/dev/null; then
    eta_h=$((eta_seconds / 3600))
    eta_m=$(((eta_seconds % 3600) / 60))
    eta=$(printf '%s: %dh %02dm' "$label" "$eta_h" "$eta_m")
  fi
fi

message="State: ${status_lc:-unknown}"
if [ -n "$capacity" ]; then
  message="$message\nCharge: ${capacity}%"
fi
if [ -n "$eta" ]; then
  message="$message\n$eta"
fi

notify-send "Battery" "$message"
