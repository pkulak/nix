#!/usr/bin/env bash
set -euo pipefail

dir="/var/lib/opencrow/sessions"
while getopts "g" opt; do
  case "$opt" in
    g) dir="/var/lib/opencrow-group/sessions" ;;
    *) echo "Usage: session [-g]" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [[ ! -d "$dir" ]]; then
  echo "Session directory does not exist: $dir" >&2
  exit 1
fi

latest=$(find "$dir" -maxdepth 1 -name '*.jsonl' -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
if [[ -z "$latest" ]]; then
  echo "No .jsonl session files found in $dir" >&2
  exit 1
fi

cd "$dir"
exec pi --session "$latest"
