#!/usr/bin/env bash

LID_STATE="$1"
MONITOR_COUNT=$(wlr-randr | grep Enabled | wc -l)

if [ $MONITOR_COUNT -gt 1 ] && [ "$LID_STATE" = "close" ]; then
    # Multiple monitors detected and lid is closed, turn off the internal display
    wlr-randr --output eDP-1 --off
    notify-send "Lid closed" "Turning off internal display" --app-name="Lid Switch"
    exit 0
fi

if [ $MONITOR_COUNT -gt 1 ] && [ "$LID_STATE" = "open" ]; then
    # Lid opened, turn on the internal display
    wlr-randr --output eDP-1 --on
    notify-send "Lid opened" "Turning on internal display" --app-name="Lid Switch"
    exit 0
fi

if [ "$LID_STATE" = "close" ]; then
    # Lid closed, no external monitor, suspend
    systemctl suspend-then-hibernate
    exit 0
fi

echo "Invalid lid state: $LID_STATE"
exit 1
