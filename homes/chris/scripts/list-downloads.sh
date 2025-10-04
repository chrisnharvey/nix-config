#!/usr/bin/env bash

FILE=$(ls -t ~/Downloads | walker -d --placeholder "Downloads...")

if [ -z "$FILE" ]; then
  echo "No file selected."
  exit 1
fi

xdg-open ~/Downloads/"$FILE"

# If exit code is 3, then we were unable to open the file.
# Open in nautilus instead
if [ $? -eq 3 ]; then
  echo "Unable to open file: $FILE"
  nautilus ~/Downloads/"$FILE"
  exit 1
fi