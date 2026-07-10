#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1
DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_TAILSCALE_IMG=v1.98.4        # https://tailscale.com                                 - curl -s "https://hub.docker.com/v2/repositories/tailscale/tailscale/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

./_cluster/scripts/tag-nodes.sh

helm repo update

"$DIR/kyverno/install.sh"

"$DIR/metallb/install.sh"

"$DIR/cert-manager/install.sh"

"$DIR/traefik/install.sh"

"$DIR/longhorn/install.sh"

"$DIR/technitium-dns/install.sh"

"$DIR/mosquitto/install.sh"

"$DIR/influxdb/install.sh"

"$DIR/telegraf/install.sh"

"$DIR/zigbee2mqtt/install.sh"

"$DIR/go2rtc/install.sh"

"$DIR/frigate/install.sh"

"$DIR/home-assistant/install.sh"

echo -e "\n\nInstalling tailscale"
echo -e "=========================================================================================="
helm upgrade tailscale ./tailscale \
  --values ./tailscale/values.yaml \
  --values ./tailscale/secrets.yaml \
  --set deployment.image.tag=$VERSION_TAILSCALE_IMG \
  --namespace tailscale \
  --create-namespace \
  --install