#!/usr/bin/env python

import os
import requests
import json

token = os.environ['HA_KEY']
headers = {"Authorization": f"Bearer {token}"}

url = "http://ha.home/api/states/sensor.co2"
response = requests.get(url, headers=headers)
co2 = int(float(response.json()["state"]))

data = {"text": f"{co2}ppm"}

print(json.dumps(data))
