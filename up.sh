#!/bin/bash
set -euo pipefail

export AGENT_UID="$(id -u)"
export AGENT_GID="$(id -g)"

chmod 700 ~/.secrets
chmod 640 ~/.secrets/GH_TOKEN ~/.secrets/GHCR_TOKEN
docker compose up -d --force-recreate
