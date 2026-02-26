#!/usr/bin/env bash
# Copy binary to a temp file, delete the original immediately, run the copy.
# This avoids "Text file busy" when competitest recompiles while a run is active,
# and ensures cleanup even if the program crashes.
tmp=$(mktemp)
cp "$1" "$tmp"
rm -f "$1"
chmod +x "$tmp"
"$tmp"
rm -f "$tmp"
