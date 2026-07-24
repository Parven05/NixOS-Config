#!/usr/bin/env bash
wall_dir="$HOME/dotfiles/wallpapers"
cache_file="$HOME/.cache/current-wallpaper"
mkdir -p "$wall_dir"
mkdir -p "$(dirname "$cache_file")"

wall_selection=$(ls "$wall_dir" | fuzzel --dmenu \
  --prompt="󰸉  " \
  --placeholder="Choose wallpaper…" \
  --width=28 \
  --lines=10)

if [ -n "$wall_selection" ]; then
  wallpaper_path="$wall_dir/$wall_selection"
  awww img "$wallpaper_path" -t grow --transition-duration 1 --transition-fps 75
  echo "$wallpaper_path" > "$cache_file"
  exit 0
else
  exit 1
fi
