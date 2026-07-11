#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1
DIR="$(cd "$(dirname "$0")" && pwd)"

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

"$DIR/grafana/install.sh"

"$DIR/zigbee2mqtt/install.sh"

"$DIR/go2rtc/install.sh"

"$DIR/frigate/install.sh"

"$DIR/home-assistant/install.sh"

"$DIR/tailscale/install.sh"