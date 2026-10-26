#!/usr/bin/env bash
set -euo pipefail

readonly workspaces=/workspaces

as_agent() { runuser -u agent -- env HOME=/home/agent "$@"; }

chown agent:agent "${workspaces}"

echo "setup: hello world"
