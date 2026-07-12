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

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
source_clip="$tmpdir/source.mp4"
rendered_clip="$tmpdir/rendered.mp4"

if [[ $kind == review ]]; then
  metadata=$(curl -fsS "$api/review/$id")
  camera=$(jq -er '.camera' <<<"$metadata")
  start_time=$(jq -er '.start_time' <<<"$metadata")
  end_time=$(jq -er '.end_time // empty' <<<"$metadata") || {
    echo "review $id is still in progress" >&2
    exit 1
  }
  start_time=$(jq -nr --argjson time "$start_time" --argjson padding "$padding" '$time - $padding')
  end_time=$(jq -nr --argjson time "$end_time" --argjson padding "$padding" '$time + $padding')
  clip_url="$api/$camera/start/$start_time/end/$end_time/clip.mp4"
else
  metadata=$(curl -fsS "$api/events/$id")
  jq -e '.end_time != null and .has_clip == true' >/dev/null <<<"$metadata" || {
    echo "event $id does not have a completed clip" >&2
    exit 1
  }
  clip_url="$api/events/$id/clip.mp4?padding=$padding"
fi

curl -fsS "$clip_url" -o "$source_clip"

ffmpeg -hide_banner -loglevel error -y -i "$source_clip" \
  -map 0:v:0 -map '0:a?' \
  -vf 'fps=8,scale=-2:360' \
  -c:v libx264 -preset veryslow -crf 26 \
  -c:a aac -b:a 64k \
  -pix_fmt yuv420p -movflags +faststart \
  "$rendered_clip"

mkdir -p "$(dirname "$output")"
mv "$rendered_clip" "$output"
printf '%s\n' "$output"
