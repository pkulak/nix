#!/usr/bin/env bash

LAST_LINE="createworkspace>>1"

handle() {
  if [[ $line == "openwindow>>"* && $LAST_LINE == "createworkspace>>1" ]]; then
    hyprctl dispatch "layoutmsg mfact 0.66"
    hyprctl dispatch "layoutmsg orientationright"
    LAST_LINE=""
  fi

  if [[ $line == "createworkspace"* ]]; then
    LAST_LINE=$1
  fi
}

socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock \
  | while read -r line; do handle "$line"; done
