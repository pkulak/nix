#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 || ( $1 != review && $1 != event ) ]]; then
  echo "usage: $0 <review|event> <id> <output.mp4>" >&2
  exit 2
fi

kind=$1
id=$2
output=$3
api=${FRIGATE_API_URL:-http://debian.home:5000/api}
padding=5
wait_seconds=90

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
rendered_clip="$tmpdir/rendered.mp4"

deadline=$((SECONDS + wait_seconds))
while true; do
  if [[ $kind == review ]]; then
    metadata=$(curl -fsS "$api/review/$id")
    jq -e '.end_time != null' >/dev/null <<<"$metadata" && break
  else
    metadata=$(curl -fsS "$api/events/$id")
    jq -e '.end_time != null and .has_clip == true' >/dev/null <<<"$metadata" && break
  fi

  if ((SECONDS >= deadline)); then
    echo "$kind $id did not have a completed clip after $wait_seconds seconds" >&2
    exit 1
  fi
  sleep 2
done

if [[ $kind == review ]]; then
  camera=$(jq -er '.camera' <<<"$metadata")
  start_time=$(jq -er '.start_time' <<<"$metadata")
  end_time=$(jq -er '.end_time' <<<"$metadata")
  start_time=$(jq -nr --argjson time "$start_time" --argjson padding "$padding" '$time - $padding')
  end_time=$(jq -nr --argjson time "$end_time" --argjson padding "$padding" '$time + $padding')
  clip_url="$api/$camera/start/$start_time/end/$end_time/clip.mp4"
else
  clip_url="$api/events/$id/clip.mp4?padding=$padding"
fi

ffmpeg -hide_banner -loglevel error -y \
  -hwaccel vaapi -hwaccel_output_format vaapi \
  -vaapi_device /dev/dri/renderD129 \
  -i "$clip_url" \
  -map 0:v:0 -map '0:a?' \
  -vf 'scale_vaapi=w=-2:h=720:format=nv12' \
  -c:v hevc_vaapi -qp 26 -tag:v hvc1 \
  -c:a aac -b:a 64k \
  -movflags +faststart \
  "$rendered_clip"

mkdir -p "$(dirname "$output")"
mv "$rendered_clip" "$output"
printf '%s\n' "$output"
