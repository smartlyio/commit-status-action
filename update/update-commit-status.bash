#!/usr/bin/env bash

set -eu -o pipefail

declare -a ARGS
if [[ -n "$TARGET_URL" ]]; then
    ARGS=("-f" "target_url=${TARGET_URL}")
fi

gh api "/repos/${GITHUB_REPOSITORY}/statuses/${COMMIT_STATUS_SHA}" \
   -XPOST \
   -f state="$STATUS" \
   -f description="$DESCRIPTION" \
   -f context="$CONTEXT" \
   "${ARGS[@]}"
