#!/bin/bash
chmod 700 ~/.secrets
chmod 640 ~/.secrets/GH_TOKEN ~/.secrets/GHCR_TOKEN
docker compose up -d --force-recreate