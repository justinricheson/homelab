#!/usr/bin/env bash

# Labels nodes so deployments with hardware requirements go to the right place

set -euo pipefail

kubectl patch nodes.longhorn.io bl1 -n longhorn-system --type=merge -p '{"spec":{"tags":["nvr"]}}'

DISK_KEY=$(kubectl get nodes.longhorn.io bl1 -n longhorn-system -o jsonpath='{.spec.disks}' | jq -r 'keys[0]')
kubectl patch nodes.longhorn.io bl1 -n longhorn-system --type=merge -p "{\"spec\":{\"disks\":{\"$DISK_KEY\":{\"tags\":[\"nvr\"]}}}}"