#!/usr/bin/env sh

set -eu

margin_right=0
margin_bottom=32

if pgrep -x gsimplecal >/dev/null 2>&1; then
  exec gsimplecal
fi

gsimplecal &
pid=$!

wid=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
  wid="$(xdotool search --onlyvisible --pid "$pid" 2>/dev/null | head -n 1 || true)"
  if [ -n "$wid" ]; then
    break
  fi
  sleep 0.05
done

if [ -z "$wid" ]; then
  exit 0
fi

eval "$(xdotool getwindowgeometry --shell "$wid")"
set -- $(xdotool getdisplaygeometry)
screen_width=$1
screen_height=$2

x=$((screen_width - WIDTH - margin_right))
y=$((screen_height - HEIGHT - margin_bottom))

if [ "$x" -lt 0 ]; then
  x=0
fi

if [ "$y" -lt 0 ]; then
  y=0
fi

xdotool windowmove "$wid" "$x" "$y"
