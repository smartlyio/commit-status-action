if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
  SHA="${{ github.event.pull_request.head.sha }}"
else
  SHA="${{ github.sha }}"
fi
echo ::set-output name=sha::"$SHA"
