set -eu -o pipefail

cat > update_commit_status-needs.json <<EOFNEEDS
${GITHUB_NEEDS}
EOFNEEDS

ERROR=error
CANCELLED=cancelled
FAILURE=failure
SUCCESS=success

function countbyStatus() {
  local status="$1"
  local with_status=
  local count=0
  with_status="$(jq '. | with_entries(select(.value.result == "'"$status"'"))' <update_commit_status-needs.json)"
  echo "$with_status" 1>&2
  count="$(echo "$with_status" | jq '. | length')"
  echo "$count"
}
function jobsWithStatus() {
    local status="$1"
    jq -r '. | to_entries | .[] | select(.value.result == "'"$status"'") | .key' <update_commit_status-needs.json | tr $'\n' ' '
}
function jobsStatuses() {
    jq -r '. | to_entries | .[] | .key + ": " .value.result' <update_commit_status-needs.json | tr $'\n' '; ' | sed 's/; $//'
}
successes="$(countbyStatus "$SUCCESS")"
failures="$(countbyStatus "$FAILURE")"
cancelled="$(countbyStatus "$CANCELLED")"
if [[ "$cancelled" -gt 0 ]]; then
  final_result="$ERROR"
  description="Build ended as 'error' with one or more cancelled stages: $(jobsWithStatus "$CANCELLED")"
elif [[ "$failures" -gt 0 ]]; then
  final_result="$FAILURE"
  description="Build ended as 'failed' with one or more failed stages: $(jobsWithStatus "$FAILURE")"
elif [[ "$successes" -eq 0 ]]; then
  final_result="$ERROR"
  description="Build encountered unknown error with no successful stages reported. Job statuses are $(jobsStatuses)"
else
  final_result="$SUCCESS"
  description="Build succeeded"
fi
echo status="$final_result" >> "$GITHUB_OUTPUT"
echo description="$description" >> "$GITHUB_OUTPUT"
