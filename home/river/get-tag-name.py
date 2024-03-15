#!/usr/bin/env python

import json
import subprocess

tags = json.loads(subprocess.getoutput("river-bedload -print tags"))
focused = [t for t in tags if t["output"] == "HDMI-A-1" and t["focused"]]

if len(focused) == 0:
    print("scratch")
    exit

match focused[0]["id"]:
    case 1:
        print("one")
    case 2:
        print("two")
    case 3:
        print("three")
    case 4:
        print("four")
    case 5:
        print("five")
    case 6:
        print("six")
    case 8:
        print("vevo")
    case _:
        print("scratch")
