set -eu -o pipefail

if [ -n "$COMMIT_STATUS_SHA" ]; then
  SHA="$COMMIT_STATUS_SHA"
elif [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
  SHA="${{ github.event.pull_request.head.sha }}"
else
  SHA="${{ github.sha }}"
fi
echo sha="$SHA" >> "$GITHUB_OUTPUT"
