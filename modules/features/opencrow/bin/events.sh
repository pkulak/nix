#!/bin/bash

khal list today --format '{start-time} to {end-time} - {title}' | grep -iF -e 'chase' -e 'charlie' -e 'gwen' -e 'phil'
