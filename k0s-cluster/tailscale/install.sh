#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_TAILSCALE_IMG=v1.98.4 # https://tailscale.com - curl -s "https://hub.docker.com/v2/repositories/tailscale/tailscale/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

echo -e "\n\nInstalling tailscale"
echo -e "=========================================================================================="
helm upgrade tailscale "$DIR" \
  --values "$DIR/values.yaml" \
  --values "$DIR/secrets.yaml" \
  --set deployment.image.tag=$VERSION_TAILSCALE_IMG \
  --namespace tailscale \
  --create-namespace \
  --install