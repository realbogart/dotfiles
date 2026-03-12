#!/usr/bin/env sh

state_dir="${XDG_RUNTIME_DIR:-/tmp}"
state_file="$state_dir/toggle-media-last-player"

services=$(busctl --user list 2>/dev/null | awk '{print $1}' | rg '^org\.mpris\.MediaPlayer2\.' || true)
[ -z "$services" ] && exit 0

is_playing() {
  status=$(busctl --user get-property "$1" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player PlaybackStatus 2>/dev/null | awk -F '"' 'NF>=2{print $2}')
  [ "$status" = "Playing" ]
}

toggle() {
  busctl --user call "$1" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player PlayPause >/dev/null 2>&1
}

first_playing=""
for s in $services; do
  if is_playing "$s"; then
    first_playing="$s"
    break
  fi
done

target="$first_playing"

if [ -z "$target" ] && [ -r "$state_file" ]; then
  last=$(cat "$state_file" 2>/dev/null)
  for s in $services; do
    if [ "$s" = "$last" ]; then
      target="$s"
      break
    fi
  done
fi

if [ -z "$target" ]; then
  for s in $services; do
    target="$s"
    break
  done
fi

if [ -n "$target" ] && toggle "$target"; then
  printf '%s\n' "$target" > "$state_file"
  exit 0
fi

for s in $services; do
  if toggle "$s"; then
    printf '%s\n' "$s" > "$state_file"
    exit 0
  fi
done

exit 0
