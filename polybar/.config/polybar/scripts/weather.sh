#!/usr/bin/env bash
# Weather module for polybar — wttr.in one-liner
result=$(curl -sf 'https://wttr.in/?format=1' 2>/dev/null | sed 's/+//g')
[ -n "$result" ] && echo "$result"
