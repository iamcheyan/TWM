#!/usr/bin/env bash

# Restart polybar to apply config changes on i3 reload.
if command -v polybar >/dev/null 2>&1; then
  if [ -z "${POLYBAR_BAT:-}" ]; then
    for bat in /sys/class/power_supply/BAT*; do
      [ -e "$bat" ] || continue
      export POLYBAR_BAT="$(basename "$bat")"
      break
    done
  fi

  if [ -z "${POLYBAR_AC:-}" ]; then
    for ac in /sys/class/power_supply/AC*; do
      [ -e "$ac" ] || continue
      export POLYBAR_AC="$(basename "$ac")"
      break
    done
  fi

  if [ -z "${POLYBAR_BACKLIGHT:-}" ]; then
    for bl in /sys/class/backlight/*; do
      [ -e "$bl" ] || continue
      export POLYBAR_BACKLIGHT="$(basename "$bl")"
      break
    done
  fi

  polybar-msg cmd quit >/dev/null 2>&1 || true
  killall -q polybar || true

  while pgrep -x polybar >/dev/null 2>&1; do
    sleep 0.2
  done

  polybar -c "$HOME/.config/TWM/polybar/config.ini" main &
fi
