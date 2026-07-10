#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_MOSQUITTO_IMG=2.0.22 # https://hub.docker.com/_/eclipse-mosquitto - curl -s "https://hub.docker.com/v2/repositories/library/eclipse-mosquitto/tags?page_size=100" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

echo -e "\n\nInstalling mosquitto"
echo -e "=========================================================================================="
helm upgrade mosquitto "$DIR" \
  --values "$DIR/values.yaml" \
  --values "$DIR/secrets.yaml" \
  --set deployment.image.tag=$VERSION_MOSQUITTO_IMG \
  --namespace mosquitto \
  --create-namespace \
  --install