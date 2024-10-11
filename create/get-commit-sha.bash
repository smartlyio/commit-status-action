set -eu -o pipefail

if [ -n "$COMMIT_STATUS_SHA" ]; then
  SHA="$COMMIT_STATUS_SHA"
elif [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
  SHA="$PULL_REQUEST_SHA"
else
  SHA="$GITHUB_SHA"
fi
echo sha="$SHA" >> "$GITHUB_OUTPUT"
