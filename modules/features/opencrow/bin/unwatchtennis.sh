#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <url>" >&2
  exit 1
fi

: "${CHANGE_TOKEN:?CHANGE_TOKEN must be set}"

api_url="https://change.kulak.us/api/v1/watch"
target_url="$1"

watches="$(curl -fsS -X GET "$api_url" \
  -H "x-api-key: $CHANGE_TOKEN")"

matches_json="$(jq --arg target "$target_url" '
  def canonical_url:
    tostring
    | sub("[?#].*$"; "")
    | sub("/+$"; "")
    | capture("^(?:(?<scheme>[^:/?#]+)://)?(?<host>[^/?#]*)(?<path>/.*)?$") as $u
    | (($u.host | ascii_downcase) + ($u.path // ""));

  ($target | canonical_url) as $canonical_target
  | (to_entries
     | map(
         . as $entry
         | .value as $watch
         | [($watch.url // ""), ($watch.link // "")] as $urls
         | (if ($urls | index($target)) then 2
            elif ($urls | map(canonical_url) | index($canonical_target)) then 1
            else 0 end) as $score
         | select($score > 0)
         | {
             score: $score,
             uuid: ($watch.uuid // $entry.key),
             title: ($watch.title // $watch.page_title // ""),
             url: ($watch.url // $watch.link // "")
           }
       )) as $matches
  | ($matches | map(.score) | max // 0) as $max_score
  | $matches
  | map(select(.score == $max_score))
' <<<"$watches")"

match_count="$(jq 'length' <<<"$matches_json")"

case "$match_count" in
  0)
    echo "No changedetection.io watch found for $target_url" >&2
    exit 1
    ;;
  1)
    ;;
  *)
    echo "Multiple changedetection.io watches matched $target_url:" >&2
    jq -r '.[] | "  \(.uuid)\t\(.title)\t\(.url)"' <<<"$matches_json" >&2
    exit 1
    ;;
esac

uuid="$(jq -r '.[0].uuid' <<<"$matches_json")"
title="$(jq -r '.[0].title' <<<"$matches_json")"
watch_url="$(jq -r '.[0].url' <<<"$matches_json")"

curl -fsS -X DELETE "$api_url/$uuid" \
  -H "x-api-key: $CHANGE_TOKEN" \
  >/dev/null

if [[ -n "$title" ]]; then
  echo "Removed watch $title ($uuid)"
else
  echo "Removed watch $watch_url ($uuid)"
fi
