#!/usr/bin/env bash

# Restart polybar to apply config changes on i3 reload.
if command -v polybar >/dev/null 2>&1; then
  polybar-msg cmd quit >/dev/null 2>&1 || true
  killall -q polybar || true

  while pgrep -x polybar >/dev/null 2>&1; do
    sleep 0.2
  done

  polybar -c "$HOME/.config/TWM/polybar/config.ini" main &
fi
