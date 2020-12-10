# Actions to manage github commit statuses

Contains two subdirectories for specific implementations of creating a
pending status and updating the status once a build finishes.

```
  create_status:
    runs-on: ubuntu-latest
    outputs:
      sha: ${{ steps.commit_status.outputs.commit_status_sha }}
    steps:
      - name: Create pending status
        id: commit_status
        uses: smartlyio/commit-status-action/create@master
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}

  # Other jobs ...

  finalize_status:
    runs-on: ubuntu-latest
    needs: [test, build, etc, create_status]
    if: ${{ always() }}
    steps:
      - name: Update commit status
        uses: smartlyio/commit-status-action/update@master
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          github-needs: ${{ toJson(needs) }}
          sha: ${{ needs.create_status.outputs.sha }}
```
