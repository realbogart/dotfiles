#!/usr/bin/env sh

services=$(busctl --user list 2>/dev/null | awk '{print $1}' | rg '^org\.mpris\.MediaPlayer2\.' || true)

[ -z "$services" ] && exit 0

for s in $services; do
  case "$s" in
    *brave*|*chrom*)
      if busctl --user call "$s" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player PlayPause >/dev/null 2>&1; then
        exit 0
      fi
      ;;
  esac
done

for s in $services; do
  if busctl --user call "$s" /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player PlayPause >/dev/null 2>&1; then
    exit 0
  fi
done

exit 0
