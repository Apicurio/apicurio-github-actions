# Notify Slack Action

Posts a notification to one of the two Apicurio Slack channels. Each workflow only decides the
level; the action handles routing, mentions and Slack's payload format.

| Level | Channel | Use for | Mentions |
|---|---|---|---|
| `important` | team channel | Something someone must act on: a confirmed break, a failed release or publish. Never routine. | One owner |
| `general` | notification channel | Worth knowing, no action needed: back to green, a flake, a release published. | None |

Routine success is not notified at all; it stays in the GitHub UI.

## Usage

```yaml
- name: Notify Slack
  if: failure()
  uses: apicurio/apicurio-github-actions/notify-slack@<sha> # vX.Y.Z
  with:
    level: important
    text: "Release ${{ inputs.release-version }} failed in job release-images"
    link: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
    mention: ${{ github.actor }}
    user-map: ${{ secrets.SLACK_USER_MAP }}
    important-webhook: ${{ secrets.SLACK_IMPORTANT_NOTIFICATION_WEBHOOK }}
    general-webhook: ${{ secrets.SLACK_GENERAL_NOTIFICATION_WEBHOOK }}
```

Composite actions cannot read secrets, so the caller passes them. The three secrets are
organization secrets in Apicurio and Apitomy.

See [action.yml](action.yml) for the inputs.

## Mentions

`mention` lists GitHub logins in priority order. The first one found in `user-map` is mentioned;
bots are skipped. The map is a JSON object of GitHub login (any case) to Slack member ID:

```json
{"jsenko": "U0123ABCD", "ericwittmann": "U0456EFGH"}
```

There is only one mention slot, so name everyone else in `text` as `@login`.

If nobody can be mentioned, the message is still sent, saying which logins had no mapping.
To be mentioned, ask an organization admin to add you to `SLACK_USER_MAP`.

Machine users are skipped without being reported: logins ending in `[bot]`, `apicurio-ci`, and
any listed in `machine-users`. A workflow that can run as another CI account, for example one
triggered by a release that account created, names it there:

```yaml
    mention: ${{ github.actor }}
    machine-users: apitomy-ci
```

## Slack setup

Both webhooks are Slack Workflow Builder workflows: general has the template `{text}`, important
has `{user} {text}`. Workflow Builder rejects a payload unless every variable is present and
`user` is a real member ID. An important message with nobody to mention therefore sends
`USLACKBOT`, which shows as "@Slackbot" and notifies nobody.

## Failures

- An empty webhook (forks, repositories without the secrets) logs a warning and sends nothing.
- If Slack rejects the message, the action logs a warning and does not fail the job.
- An unknown `level` fails the step: it is a mistake in the calling workflow.
- A `user-map` that is not a JSON object logs a warning; the message goes out without a mention.

## Testing

`payload.test.sh` checks the payload for each case. [test-notify-slack.yml](../.github/workflows/test-notify-slack.yml)
runs it and calls the action against a local mock webhook.
