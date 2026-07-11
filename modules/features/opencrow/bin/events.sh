#!/bin/bash

khal list today --format '({calendar}) {uid}|{start-time} to {end-time} - {title}' \
  | grep -v 2bb7c052abaf \
  | sed '1d; s/^([^)]*) //' \
  | awk -F '|' '!seen[$1]++ { sub(/^[^|]*\|/, ""); print }'
