#!/usr/bin/env python

import json
import subprocess

tags = json.loads(subprocess.getoutput("river-bedload -print tags"))
focused = [t for t in tags if t["output"] == "HDMI-A-1" and t["focused"]]

if len(focused) == 0:
    print("global")
    exit

tag = "global"

match focused[0]["id"]:
    case 1:
        tag = "one"
    case 2:
        tag = "two"
    case 3:
        tag = "three"
    case 4:
        tag = "four"
    case 5:
        tag = "five"
    case 6:
        tag = "six"
    case 8:
        tag = "vevo"

grep = subprocess.run('tmux list-sessions | grep "(attached)" | grep ' + tag, shell=True, capture_output=True)

# if we are already attached, open up the global session
if grep.returncode == 0:
    print("global")
else:
    print(tag)
