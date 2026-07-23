#!/usr/bin/env bash
wall_dir="$HOME/dotfiles/wallpapers"
mkdir -p "$wall_dir"

wall_selection=$(ls "$wall_dir" | fuzzel --dmenu \
  --prompt="󰸉  " \
  --placeholder="Choose wallpaper…" \
  --width=60 \
  --lines=12)

if [ -n "$wall_selection" ]; then
  awww img "$wall_dir/$wall_selection" -t grow --transition-duration 1 --transition-fps 75
  sleep 0.2
  colorwaybar "$wall_dir/$wall_selection"
  exit 0
else
  exit 1
fi
