#!/usr/bin/env bash
shutdown="⏻   Shutdown"
reboot="󰑐   Reboot"
suspend="󰤄   Suspend"
logout="󰍃   Logout"

chosen="$(printf '%s\n%s\n%s\n%s\n' \
  "$shutdown" "$reboot" "$suspend" "$logout" \
  | fuzzel --dmenu \
    --prompt="󰐥  " \
    --placeholder="Power menu…" \
    --width=40 \
    --lines=4)"

case "$chosen" in
  "$shutdown") poweroff ;;
  "$reboot")   reboot ;;
  "$suspend")  systemctl suspend ;;
  "$logout")   niri msg action quit ;;
  *)           exit 0 ;;
esac
