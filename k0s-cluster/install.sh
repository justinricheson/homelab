#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1
DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_FRIGATE_HELM=7.8.0           # https://frigate.video                                 - helm search repo blakeblackshear/frigate --versions | grep -v 'alpha\|beta\|rc' | head -5
VERSION_FRIGATE_IMG=0.17.1           # https://frigate.video                                 - curl -s "https://api.github.com/repos/blakeblackshear/frigate/releases/latest" | jq -r '.tag_name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5
VERSION_HA_HELM=0.3.63               # https://github.com/pajikos/home-assistant-helm-chart  - helm search repo pajikos/home-assistant --versions | grep -v 'alpha\|beta\|rc' | head -5
VERSION_TAILSCALE_IMG=v1.98.4        # https://tailscale.com                                 - curl -s "https://hub.docker.com/v2/repositories/tailscale/tailscale/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

./_cluster/scripts/tag-nodes.sh

helm repo update
helm repo add blakeblackshear https://blakeblackshear.github.io/blakeshome-charts
helm repo add pajikos http://pajikos.github.io/home-assistant-helm-chart

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

echo -e "\n\nInstalling frigate-prep"
echo -e "=========================================================================================="
helm upgrade frigate-prep ./frigate-prep \
  --values ./frigate-prep/values.yaml \
  --namespace frigate \
  --create-namespace \
  --install

echo -e "\n\nInstalling frigate"
echo -e "=========================================================================================="
helm upgrade frigate blakeblackshear/frigate \
  --version $VERSION_FRIGATE_HELM \
  --values ./frigate/values.yaml \
  --set image.tag=$VERSION_FRIGATE_IMG \
  --namespace frigate \
  --create-namespace \
  --install
./frigate/scripts/patch-service-port-name.sh

echo -e "\n\nInstalling frigate-post"
echo -e "=========================================================================================="
helm upgrade frigate-post ./frigate-post \
  --values ./frigate-post/values.yaml \
  --namespace frigate \
  --create-namespace \
  --install

echo -e "\n\nInstalling home-assistant-prep"
echo -e "=========================================================================================="
kubectl delete job home-assistant-config-init -n home-assistant
helm upgrade home-assistant-prep ./home-assistant-prep \
  --values ./home-assistant-prep/values.yaml \
  --namespace home-assistant \
  --create-namespace \
  --install

echo -e "\n\nInstalling home-assistant"
echo -e "=========================================================================================="
helm upgrade home-assistant pajikos/home-assistant \
  --version $VERSION_HA_HELM \
  --values ./home-assistant/values.yaml \
  --namespace home-assistant \
  --create-namespace \
  --install

echo -e "\n\nInstalling tailscale"
echo -e "=========================================================================================="
helm upgrade tailscale ./tailscale \
  --values ./tailscale/values.yaml \
  --values ./tailscale/secrets.yaml \
  --set deployment.image.tag=$VERSION_TAILSCALE_IMG \
  --namespace tailscale \
  --create-namespace \
  --install