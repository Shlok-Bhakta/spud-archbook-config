#!/usr/bin/env bash
# bench-pch.sh — benchmark compile times for the current competitest config
# Usage: ./bench-pch.sh [test_file.cpp]

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
CPP_DUMP="$DOTFILES/cpp-dump"
PCH_FILE="$DOTFILES/pch/stdc++.h.pch"
TEST_FILE="${1:-/home/shlok/Competitive/A. Watermelon/A. Watermelon.cpp}"

echo "=== compile benchmark ==="
echo "  g++:      $(g++ --version | head -1)"
echo "  clang++:  $(clang++ --version | head -1)"
echo "  file:     $TEST_FILE"
echo ""

run() {
  local label="$1"; shift
  local start end
  start=$(date +%s%3N)
  "$@" -o /tmp/ct_bench_out 2>&1
  end=$(date +%s%3N)
  echo "  $((end - start))ms  $label"
}

echo "--- g++ baseline ---"
run "g++ (no PCH)" g++ -std=c++23 -DLOCAL_DEBUG -I"$CPP_DUMP" "$(FABSPATH)" "$TEST_FILE"

echo ""
echo "--- clang++ + PCH (current config) ---"
if [[ ! -f "$PCH_FILE" ]]; then
  echo "  PCH not built yet — run ./setup-pch.sh first"
else
  for i in 1 2 3; do
    run "clang++ -include-pch (run $i)" \
      clang++ -std=c++23 -DLOCAL_DEBUG -I"$CPP_DUMP" -include-pch "$PCH_FILE" "$TEST_FILE"
  done
fi

echo ""
rm -f /tmp/ct_bench_out
echo "done."
