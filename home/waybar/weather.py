#!/usr/bin/env python

import requests
import json

token = open('/run/agenix/ha-secrets').read().strip()

url = "http://ha.home/api/states/sensor.temperature"
headers = {'Authorization': f"Bearer {token}"}

response = requests.get(url, headers=headers)

temp = round(float(response.json()['state']), 1)

data = {
    "text": f"{temp}°"
}

print(json.dumps(data))
