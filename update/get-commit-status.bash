cat > update_commit_status-needs.json <<EOFNEEDS
${GITHUB_NEEDS}
EOFNEEDS

function countbyStatus() {
  local status="$1"
  local count=0
  jq '. | with_entries(select(.value.result == "'"$status"'"))' <update_commit_status-needs.json 1>&2
  count="$(jq '. | with_entries(select(.value.result == "'"$status"'")) | length' <update_commit_status-needs.json)"
  echo "$count"
}
function jobsWithStatus() {
    local status="$1"
    jq -r '. | to_entries | .[] | select(.value.result == "'"$status"'") | .key' <update_commit_status-needs.json | tr $'\n' ' '
}
function jobsStatuses() {
    jq -r '. | to_entries | .[] | .key + ": " .value.result' <update_commit_status-needs.json | tr $'\n' '; ' | sed 's/; $//'
}
successes="$(countbyStatus "success")"
failures="$(countbyStatus "failure")"
cancelled="$(countbyStatus "cancelled")"
if [[ "$cancelled" -gt 0 ]]; then
  final_result="error"
  description="Build ended as 'error' with one or more cancelled stages: $(jobsWithStatus "cancelled")"
elif [[ "$failures" -gt 0 ]]; then
  final_result="failure"
  description="Build ended as 'failed' with one or more failed stages: $(jobsWithStatus "failure")"
elif [[ "$successes" -eq 0 ]]; then
  final_result="error"
  description="Build encountered unknown error with no successful stages reported. Job statuses are $(jobsStatuses)"
else
  final_result="success"
  description="Build succeeded"
fi
echo ::set-output name=status::"$final_result"
echo ::set-output name=description::"$description"
