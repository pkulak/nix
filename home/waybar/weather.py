#!/usr/bin/env python

import keyring
import requests
import json

token = keyring.get_password("nix", "ha")
headers = {"Authorization": f"Bearer {token}"}

url = "http://ha.home/api/states/sensor.temperature"
response = requests.get(url, headers=headers)
temp = round(float(response.json()["state"]), 1)

url = "http://ha.home/api/states/sensor.precipitation_per_hour"
response = requests.get(url, headers=headers)
precip = round(float(response.json()["state"]), 1)

url = "http://ha.home/api/states/sun.sun"
response = requests.get(url, headers=headers)
sun = response.json()["state"]

url = "http://ha.home/api/states/sensor.illuminance"
response = requests.get(url, headers=headers)
lux = int(response.json()["state"])

icon = ""

if precip == 0:
    if lux > 40000:
        icon = "\U0000f185"
    elif sun == "above_horizon":
        icon = "\U0000f0c2"
    else:
        icon = "\U0000f186"
elif precip < 3:
    icon = "\U0000f73d"
else:
    icon = "\U0000f740"

precip_str = f"   {precip} "

if precip == 0.0:
    precip_str = ""

data = {"text": f"{temp}° {precip_str}{icon}"}

print(json.dumps(data))
