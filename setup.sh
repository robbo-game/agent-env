#!/usr/bin/env bash
set -euo pipefail

readonly workspaces=/workspaces

as_agent() { runuser -u agent -- env HOME=/home/agent "$@"; }

chown agent:agent "${workspaces}"

cd "${workspaces}"

if [ -r /run/secrets/GH_TOKEN ]; then
  export GH_TOKEN="$(cat /run/secrets/GH_TOKEN)"
fi

echo "setup: fetching the list of robbo-game repositories" >&2
repos=$(as_agent gh api --paginate 'orgs/robbo-game/repos?per_page=100' --jq '.[].name')

while IFS= read -r repo; do
  [ -n "${repo}" ] || continue
  if [ ! -d "${repo}" ]; then
    echo "setup: cloning ${repo}" >&2
    as_agent gh repo clone "robbo-game/${repo}"
  else
    echo "setup: skipping existing directory ${repo}" >&2
  fi
done <<< "${repos}"

echo "setup: complete" >&2
