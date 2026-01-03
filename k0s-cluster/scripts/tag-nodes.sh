#!/usr/bin/env bash

# Labels nodes so deployments with hardware requirements go to the right place

set -euo pipefail

kubectl label nodes bl1 role=nvr