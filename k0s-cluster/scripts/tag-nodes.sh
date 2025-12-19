#!/usr/bin/env bash

# Taints nodes so deployments with hardware requirements go to the right place

set -euo pipefail

kubectl taint nodes bl1 dedicated=nvr:NoSchedule --overwrite
kubectl label nodes bl1 role=nvr