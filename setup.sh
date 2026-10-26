#!/usr/bin/env bash
set -euo pipefail

readonly workspaces=/workspaces

as_agent() { runuser -u agent -- env HOME=/home/agent "$@"; }

chown agent:agent "${workspaces}"

cd "${workspaces}"

repos=$(as_agent gh api --paginate 'orgs/robbo-game/repos?per_page=100' --jq '.[].name')

while IFS= read -r repo; do
  [ -n "${repo}" ] || continue
  if [ ! -d "${repo}" ]; then
    as_agent gh repo clone "robbo-game/${repo}"
  fi
done <<< "${repos}"
