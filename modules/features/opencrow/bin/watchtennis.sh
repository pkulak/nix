#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <url> <title>" >&2
  exit 1
fi

curl -s -X POST "https://change.kulak.us/api/v1/watch" \
  -H "x-api-key: $CHANGE_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg url "$1" --arg title "$2" '{
    url: $url,
    title: $title,
    include_filters: ["div.activity-enrollment"]
  }')"
