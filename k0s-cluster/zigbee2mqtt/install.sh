#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_ZIGBEE2MQTT_IMG=2.11.0 # https://www.zigbee2mqtt.io - curl -s "https://hub.docker.com/v2/repositories/koenkk/zigbee2mqtt/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

echo -e "\n\nInstalling zigbee2mqtt"
echo -e "=========================================================================================="
helm upgrade zigbee2mqtt "$DIR" \
  --values "$DIR/values.yaml" \
  --values "$DIR/secrets.yaml" \
  --set deployment.image.tag=$VERSION_ZIGBEE2MQTT_IMG \
  --namespace zigbee2mqtt \
  --create-namespace \
  --install