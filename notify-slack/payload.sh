#!/usr/bin/env bash
# Builds the Slack payload for the notify-slack action and prints it.
# Input comes from the environment: LEVEL, TEXT, LINK, MENTION, USER_MAP.
#
# The webhooks are Slack Workflow Builder workflows. General takes {text};
# important takes {user} {text}. Workflow Builder rejects a payload unless
# every variable is present and user is a real member ID, so important always
# sends one: the first mentioned login with a Slack mapping, or USLACKBOT,
# which renders as "@Slackbot" and notifies nobody.
set -euo pipefail

PLACEHOLDER_USER=USLACKBOT
# Machine users without the "[bot]" suffix GitHub apps get.
MACHINE_USERS=" apicurio-ci "

message=$TEXT
if [[ -n "${LINK:-}" ]]; then
  message+=$'\n'$LINK
fi

case "$LEVEL" in
  general)
    if [[ -n "${MENTION:-}" ]]; then
      echo "::warning::notify-slack: mention is ignored for level 'general'" >&2
    fi
    jq -n --arg text "$message" '{text: $text}'
    ;;

  important)
    map=${USER_MAP:-}
    if [[ -z "$map" ]]; then
      map='{}'
    fi
    # A broken map must never drop the message, only the mention.
    if ! map=$(jq -c 'with_entries(.key |= ascii_downcase)' <<< "$map" 2> /dev/null); then
      echo "::warning::notify-slack: user-map is not a JSON object, sending without a mention" >&2
      map='{}'
    fi

    user=""
    unmapped=()
    IFS=', ' read -ra logins <<< "${MENTION:-}"
    for login in "${logins[@]}"; do
      login=${login,,}
      if [[ "$login" == *"[bot]" || "$MACHINE_USERS" == *" $login "* ]]; then
        continue
      fi
      user=$(jq -r --arg login "$login" '.[$login] // empty' <<< "$map")
      if [[ -n "$user" ]]; then
        break
      fi
      unmapped+=("@$login")
    done

    if [[ -z "$user" ]]; then
      user=$PLACEHOLDER_USER
      if (( ${#unmapped[@]} > 0 )); then
        printf -v joined '%s, ' "${unmapped[@]}"
        message+=$'\n'"Nobody mentioned: no Slack mapping for ${joined%, }."
      fi
    fi
    jq -n --arg user "$user" --arg text "$message" '{user: $user, text: $text}'
    ;;

  *)
    echo "::error::notify-slack: unknown level '$LEVEL', expected 'important' or 'general'" >&2
    exit 1
    ;;
esac
