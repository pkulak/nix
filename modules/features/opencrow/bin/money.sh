#!/usr/bin/env bash
# Money bot CLI — check balances and transfer funds via the money bot API.
# Usage: money.sh <command> [args...]

set -euo pipefail

API="http://lilnas.home:8386"

cmd="${1:-help}"
shift || true

api() {
  xh --ignore-stdin --check-status -b -A bearer -a "$MONEY_API_TOKEN" "$@"
}

case "$cmd" in
  balance)
    # Show a user's current balance: money.sh balance charlie
    user="${1:?Usage: money.sh balance <user>}"
    api GET "$API/balance/$user" | jq -r '.balance'
    ;;

  transfer|send)
    # Transfer money: money.sh transfer <from> <to> <amount> [memo...]
    from="${1:?Usage: money.sh transfer <from> <to> <amount> [memo]}"
    to="${2:?Usage: money.sh transfer <from> <to> <amount> [memo]}"
    amount="${3:?Usage: money.sh transfer <from> <to> <amount> [memo]}"
    shift 3
    memo="$*"
    if [[ -n "$memo" ]]; then
      api POST "$API/transfer" from="$from" to="$to" amount="$amount" memo="$memo" >/dev/null
    else
      api POST "$API/transfer" from="$from" to="$to" amount="$amount" >/dev/null
    fi
    echo "✓ Sent $amount to $to from $from"
    ;;

  help|*)
    cat <<EOF
Money bot CLI

Usage: money <command> [args...]

Commands:
  balance <user>                       Show a user's current balance
  transfer <from> <to> <amount> [memo] Transfer money between users

Environment:
  MONEY_API_TOKEN   Bearer token for the money API (required)

Examples:
  money balance charlie
  money transfer dad charlie 5.00 weekly allowance
EOF
    ;;
esac
