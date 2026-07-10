#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_TECHNITIUM_IMG=15.2.0        # https://technitium.com/dns                            - curl -s "https://hub.docker.com/v2/repositories/technitium/dns-server/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5
VERSION_TECHNITIUM_CONFIG_IMG=v2.0.0 # https://github.com/ashtonian/technitium-configurator  - curl -s "https://api.github.com/repos/ashtonian/technitium-configurator/tags" | jq -r '.[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

echo -e "\n\nInstalling technitium-dns"
echo -e "=========================================================================================="
helm upgrade technitium-dns "$DIR" \
  --values "$DIR/values.yaml" \
  --set deployment.image.tag=$VERSION_TECHNITIUM_IMG \
  --namespace technitium-dns \
  --create-namespace \
  --install

echo -e "\n\nInstalling technitium-dns-post"
echo -e "=========================================================================================="
helm upgrade technitium-dns-post "$DIR/post" \
  --values "$DIR/post/values.yaml" \
  --values "$DIR/post/secrets.yaml" \
  --namespace technitium-dns \
  --create-namespace \
  --install