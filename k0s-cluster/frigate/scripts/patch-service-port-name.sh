#!/usr/bin/env bash

# The frigate helm creates an https port with non-standard naming
# This causes traefik to not recognize it as an https port
# This script renames the port to fix it so traefik can call
# the backend via https

set -euo pipefail

kubectl patch service frigate \
  -n frigate \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/ports/1/name", "value":"https-auth"}]'