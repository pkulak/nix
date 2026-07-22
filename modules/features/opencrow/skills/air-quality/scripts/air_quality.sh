#!/usr/bin/env bash
set -euo pipefail

url='https://near-me.airfire.org/fasm/monitor?lat=45.568259&lng=-122.631719&maxDistanceMiles=20&limit=10'

curl --fail --silent --show-error "$url" | jq '
  def category:
    if . <= 50 then "Good"
    elif . <= 100 then "Moderate"
    elif . <= 150 then "Unhealthy for sensitive groups"
    elif . <= 200 then "Unhealthy"
    elif . <= 300 then "Very unhealthy"
    else "Hazardous"
    end;

  [.purpleAir[]
    | select(
        .status == 0
        and (.aqi | type) == "number"
        and (.nowcast | type) == "number"
      )
  ]
  | sort_by(.distanceMiles)
  | first as $monitor
  | if $monitor == null then
      error("No current PurpleAir reading is available")
    else
      {
        aqi: $monitor.aqi,
        category: ($monitor.aqi | category),
        pm25: $monitor.nowcast,
        pm25Unit: "µg/m³",
        observedAt: $monitor.local_ts,
        source: "PurpleAir",
        sensorId: $monitor.unit_id,
        distanceMiles: $monitor.distanceMiles
      }
    end
'
