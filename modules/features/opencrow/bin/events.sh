#!/bin/bash

khal list today --format '({calendar}) {start-time} to {end-time} - {title}' \
  | grep -v 2bb7c052abaf \
  | sed '1d; s/^([^)]*) //'
