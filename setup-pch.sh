#!/usr/bin/env bash
# setup-pch.sh — build the clang PCH for bits/stdc++.h
# Run this once after cloning dotfiles, and again after clang upgrades.
#
# Usage: ./setup-pch.sh

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PCH_DIR="$DOTFILES/pch"
CPP_DUMP="$DOTFILES/cpp-dump"
PCH_SRC="$PCH_DIR/stdc++.h"
PCH_OUT="$PCH_DIR/stdc++.h.pch"

# find system bits/stdc++.h for the active clang version
SYSTEM_BITS=$(clang++ -std=c++23 -v -x c++ /dev/null -fsyntax-only 2>&1 \
  | grep -oP '(?<=-I ).*' | head -1 | xargs -I{} find {} -name "stdc++.h" 2>/dev/null | head -1)

if [[ -z "$SYSTEM_BITS" ]]; then
  # fallback: search common paths
  SYSTEM_BITS=$(find /usr/include -name "stdc++.h" 2>/dev/null | grep -v "32" | head -1)
fi

if [[ -z "$SYSTEM_BITS" ]]; then
  echo "error: could not find bits/stdc++.h" >&2
  exit 1
fi

echo "source:  $SYSTEM_BITS"
echo "output:  $PCH_OUT"
echo ""

mkdir -p "$PCH_DIR"
cp "$SYSTEM_BITS" "$PCH_SRC"

echo -n "building PCH... "
start=$(date +%s%3N)
clang++ -std=c++23 -DLOCAL_DEBUG -I"$CPP_DUMP" \
  -x c++-header "$PCH_SRC" \
  -o "$PCH_OUT"
end=$(date +%s%3N)
echo "$((end - start))ms"
echo ""
echo "done. PCH size: $(du -h "$PCH_OUT" | cut -f1)"
