#!/usr/bin/env bash
# macOS-style lock screen using i3lock-color
# Catppuccin Mocha palette

BG="1e1e2eff"        # base - solid dark background
FG="cdd6f4ff"        # text - light lavender
SUBTEXT="6c7086ff"   # overlay0 - muted hint text
ACCENT="8aadf4ff"    # blue - focused accent
RED="f38ba8ff"       # red - wrong password
GREEN="a6e3a1ff"     # green - verified
RING="313244ff"      # surface0 - ring background
BOX="1e1e2ecc"       # base with slight transparency for box

USERNAME=$(whoami)

i3lock \
  --nofork \
  \
  `# ── Background ──────────────────────────────` \
  --color="$BG" \
  \
  `# ── Clock / Date ────────────────────────────` \
  --clock \
  --time-str="%H:%M" \
  --date-str="%A, %B %d" \
  --time-font="CaskaydiaCove Nerd Font" \
  --date-font="CaskaydiaCove Nerd Font" \
  --time-size=64 \
  --date-size=20 \
  --time-color="$FG" \
  --date-color="$SUBTEXT" \
  --time-pos="ix:iy-160" \
  --date-pos="ix:iy-110" \
  \
  `# ── Username label ──────────────────────────` \
  --greeter-text="$USERNAME" \
  --greeter-font="CaskaydiaCove Nerd Font" \
  --greeter-size=22 \
  --greeter-color="$FG" \
  --greeter-pos="ix:iy-48" \
  \
  `# ── Password input box ──────────────────────` \
  --pass-media-keys \
  --indicator \
  --radius=4 \
  --ring-width=2 \
  \
  `# ── Ring / indicator colors ─────────────────` \
  --inside-color="$RING" \
  --insidever-color="$RING" \
  --insidewrong-color="$RING" \
  --ring-color="$RING" \
  --ringver-color="${GREEN}" \
  --ringwrong-color="${RED}" \
  --line-uses-inside \
  \
  `# ── Key press feedback ──────────────────────` \
  --keyhl-color="$ACCENT" \
  --bshl-color="${RED}" \
  \
  `# ── Status text (verifying / wrong) ─────────` \
  --verif-text="verifying..." \
  --wrong-text="try again" \
  --noinput-text="" \
  --verif-font="CaskaydiaCove Nerd Font" \
  --wrong-font="CaskaydiaCove Nerd Font" \
  --verif-size=14 \
  --wrong-size=14 \
  --verif-color="$FG" \
  --wrong-color="${RED}" \
  --verif-pos="ix:iy+28" \
  --wrong-pos="ix:iy+28" \
  \
  `# ── Separator ───────────────────────────────` \
  --separator-color="00000000"
