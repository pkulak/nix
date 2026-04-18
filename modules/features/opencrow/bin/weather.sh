#!/bin/bash

curl -s "wttr.in?format=j1" | jq '{
  location: .nearest_area[0].areaName[0].value,
  weather: [.weather[0,1] | {
    date,
    hourly: [.hourly[] | {
      time: ((.time | tonumber / 100) as $h |
        if $h == 0 then "12:00 AM"
        elif $h < 12 then "\($h | floor):00 AM"
        elif $h == 12 then "12:00 PM"
        else "\($h - 12 | floor):00 PM"
        end),
      tempF,
      weatherDesc: .weatherDesc[0].value,
      chanceofrain,
      chanceofsnow,
      cloudcover,
      humidity,
      windspeedMiles
    }]
  }]
}'
