#!/usr/bin/env bash
# Tests for payload.sh. Run: notify-slack/payload.test.sh
set -uo pipefail

SCRIPT="$(dirname "$0")/payload.sh"
MAP='{"CarlesArnal": "U111", "jsenko": "U222"}'
failures=0

# check <name> <expected JSON> -- <env assignments...>
check() {
  local name=$1 expected=$2
  shift 3
  local actual
  if ! actual=$(env -i PATH="$PATH" "$@" "$SCRIPT" 2> /dev/null); then
    echo "FAIL $name: exited non-zero"
    failures=$((failures + 1))
  elif [[ "$(jq -S . <<< "$actual")" != "$(jq -S . <<< "$expected")" ]]; then
    echo "FAIL $name"
    echo "  expected: $(jq -c . <<< "$expected")"
    echo "  actual:   $(jq -c . <<< "$actual")"
    failures=$((failures + 1))
  else
    echo "ok   $name"
  fi
}

# Bots are skipped, unmapped logins are passed over, lookup ignores case on both
# sides, and quotes and newlines in the text survive.
check "important: first mapped login gets the mention" \
  '{"user": "U111", "text": "main broke: \"Fix #1\"\nsecond line\nhttps://example.com/run/1"}' -- \
  LEVEL=important TEXT=$'main broke: "Fix #1"\nsecond line' LINK=https://example.com/run/1 \
  MENTION='renovate[bot], apicurio-ci,eameh,CARLESARNAL,jsenko' USER_MAP="$MAP"

# An unusable map loses the mention, never the message.
check "important: no mapping falls back to the placeholder and says why" \
  '{"user": "USLACKBOT", "text": "Release failed\nNobody mentioned: no Slack mapping for @eameh, @someone."}' -- \
  LEVEL=important TEXT='Release failed' MENTION='eameh someone' USER_MAP='not json'

check "important: no mention at all" \
  '{"user": "USLACKBOT", "text": "Release failed"}' -- \
  LEVEL=important TEXT='Release failed'

check "general: text only, mention ignored" \
  '{"text": "main is green again\nhttps://example.com/run/2"}' -- \
  LEVEL=general TEXT='main is green again' LINK=https://example.com/run/2 \
  MENTION=jsenko USER_MAP="$MAP"

if env -i PATH="$PATH" LEVEL=urgent TEXT=x "$SCRIPT" > /dev/null 2>&1; then
  echo "FAIL unknown level: exited zero"
  failures=$((failures + 1))
else
  echo "ok   unknown level fails"
fi

if (( failures > 0 )); then
  echo "$failures test(s) failed"
  exit 1
fi
echo "All tests passed"
