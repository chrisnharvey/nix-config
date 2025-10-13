#!/usr/bin/env bash
# Script to monitor and restart waybar if it crashes

while true; do
    # Start waybar
    waybar

    # If waybar exits, log it and restart after a short delay
    echo "$(date): waybar crashed, restarting in 2 seconds..."
    sleep 2
done
