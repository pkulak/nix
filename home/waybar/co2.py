#!/usr/bin/env python

import os
import requests
import json

token = os.environ['HA_KEY']
headers = {"Authorization": f"Bearer {token}"}

url = "http://ha.home/api/states/sensor.apollo_air_co2"
response = requests.get(url, headers=headers)
co2_down = int(float(response.json()["state"]))

url = "http://ha.home/api/states/sensor.awair_bunny_co2"
response = requests.get(url, headers=headers)
co2_up = int(float(response.json()["state"]))

icon = "↑"
co2 = co2_up

if co2_down > co2_up:
    icon = "↓"
    co2 = co2_down

data = {"text": f"{co2} {icon}"}

print(json.dumps(data))
