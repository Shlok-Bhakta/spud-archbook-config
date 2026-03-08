#!/usr/bin/env bash

set -u

read_value() {
  local path="$1"
  [ -r "$path" ] && tr -d '\n' < "$path"
}

print_status() {
  local bat_dir=""
  for candidate in /sys/class/power_supply/BAT*; do
    if [ -d "$candidate" ]; then
      bat_dir="$candidate"
      break
    fi
  done

  [ -z "$bat_dir" ] && return

  local status capacity status_lc charge_now charge_full current_now
  local eta eta_seconds eta_h eta_m icon

  status=$(read_value "$bat_dir/status")
  capacity=$(read_value "$bat_dir/capacity")
  status_lc=$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')

  charge_now=$(read_value "$bat_dir/charge_now")
  charge_full=$(read_value "$bat_dir/charge_full")
  current_now=$(read_value "$bat_dir/current_now")

  if [ -z "$charge_now" ] || [ -z "$charge_full" ] || [ -z "$current_now" ] || [ "$current_now" -le 0 ] 2>/dev/null; then
    eta=""
  else
    if [ "$status_lc" = "discharging" ]; then
      eta_seconds=$(awk -v e="$charge_now" -v p="$current_now" 'BEGIN { printf "%d", (e/p)*3600 }')
    elif [ "$status_lc" = "charging" ]; then
      eta_seconds=$(awk -v now="$charge_now" -v full="$charge_full" -v p="$current_now" 'BEGIN { rem=full-now; if (rem<0) rem=0; printf "%d", (rem/p)*3600 }')
    else
      eta_seconds=""
    fi

    if [ -n "$eta_seconds" ] && [ "$eta_seconds" -ge 0 ] 2>/dev/null; then
      eta_h=$((eta_seconds / 3600))
      eta_m=$(((eta_seconds % 3600) / 60))
      eta=$(printf ' %dh%02dm' "$eta_h" "$eta_m")
    else
      eta=""
    fi
  fi

  if [ -z "${capacity:-}" ]; then
    capacity="--"
  fi

  if [ "$status_lc" = "charging" ]; then
    icon="󰂄"
  elif [ "$capacity" -ge 90 ] 2>/dev/null; then
    icon="󰁹"
  elif [ "$capacity" -ge 80 ] 2>/dev/null; then
    icon="󰂂"
  elif [ "$capacity" -ge 70 ] 2>/dev/null; then
    icon="󰂁"
  elif [ "$capacity" -ge 60 ] 2>/dev/null; then
    icon="󰂀"
  elif [ "$capacity" -ge 50 ] 2>/dev/null; then
    icon="󰁿"
  elif [ "$capacity" -ge 40 ] 2>/dev/null; then
    icon="󰁾"
  elif [ "$capacity" -ge 30 ] 2>/dev/null; then
    icon="󰁽"
  elif [ "$capacity" -ge 20 ] 2>/dev/null; then
    icon="󰁼"
  elif [ "$capacity" -ge 10 ] 2>/dev/null; then
    icon="󰁻"
  else
    icon="󰁺"
  fi

  printf '%s\n' "${icon} ${capacity}%${eta}"
}

if [ "${1:-}" = "--follow" ]; then
  trap 'print_status' USR1
  print_status
  while true; do
    sleep 60 &
    wait $!
    print_status
  done
else
  print_status
fi
