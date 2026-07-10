#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1
DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_TECHNITIUM_IMG=15.2.0        # https://technitium.com/dns                            - curl -s "https://hub.docker.com/v2/repositories/technitium/dns-server/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5
VERSION_TECHNITIUM_CONFIG_IMG=v2.0.0 # https://github.com/ashtonian/technitium-configurator  - curl -s "https://api.github.com/repos/ashtonian/technitium-configurator/tags" | jq -r '.[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5
VERSION_MOSQUITTO_IMG=2.0.22         # https://hub.docker.com/_/eclipse-mosquitto            - curl -s "https://hub.docker.com/v2/repositories/library/eclipse-mosquitto/tags?page_size=100" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5
VERSION_INFLUXDB_HELM=2.1.2          # https://www.influxdata.com/products/influxdb          - helm search repo influxdata/influxdb2 --versions | grep -v 'alpha\|beta\|rc' | head -5
VERSION_TELEGRAF_HELM=1.8.73         # https://github.com/influxdata/helm-charts             - helm search repo influxdata/telegraf --versions | grep -v 'alpha\|beta\|rc' | head -5
VERSION_ZIGBEE2MQTT_IMG=2.11.0       # https://www.zigbee2mqtt.io                            - curl -s "https://hub.docker.com/v2/repositories/koenkk/zigbee2mqtt/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5
VERSION_GO2RTC_IMG=1.9.14            # https://github.com/AlexxIT/go2rtc                     - curl -s "https://hub.docker.com/v2/repositories/alexxit/go2rtc/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5
VERSION_FRIGATE_HELM=7.8.0           # https://frigate.video                                 - helm search repo blakeblackshear/frigate --versions | grep -v 'alpha\|beta\|rc' | head -5
VERSION_FRIGATE_IMG=0.17.1           # https://frigate.video                                 - curl -s "https://api.github.com/repos/blakeblackshear/frigate/releases/latest" | jq -r '.tag_name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5
VERSION_HA_HELM=0.3.63               # https://github.com/pajikos/home-assistant-helm-chart  - helm search repo pajikos/home-assistant --versions | grep -v 'alpha\|beta\|rc' | head -5
VERSION_TAILSCALE_IMG=v1.98.4        # https://tailscale.com                                 - curl -s "https://hub.docker.com/v2/repositories/tailscale/tailscale/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

./_cluster/scripts/tag-nodes.sh

helm repo update
helm repo add blakeblackshear https://blakeblackshear.github.io/blakeshome-charts
helm repo add pajikos http://pajikos.github.io/home-assistant-helm-chart
helm repo add influxdata https://helm.influxdata.com

"$DIR/kyverno/install.sh"

"$DIR/metallb/install.sh"

"$DIR/cert-manager/install.sh"

"$DIR/traefik/install.sh"

"$DIR/longhorn/install.sh"

echo -e "\n\nInstalling technitium-dns"
echo -e "=========================================================================================="
helm upgrade technitium-dns ./technitium-dns \
  --values ./technitium-dns/values.yaml \
  --set deployment.image.tag=$VERSION_TECHNITIUM_IMG \
  --namespace technitium-dns \
  --create-namespace \
  --install

echo -e "\n\nInstalling technitium-dns-post"
echo -e "=========================================================================================="
helm upgrade technitium-dns-post ./technitium-dns-post \
  --values ./technitium-dns-post/values.yaml \
  --values ./technitium-dns-post/secrets.yaml \
  --namespace technitium-dns \
  --create-namespace \
  --install

echo -e "\n\nInstalling mosquitto"
echo -e "=========================================================================================="
helm upgrade mosquitto ./mosquitto \
  --values ./mosquitto/values.yaml \
  --values ./mosquitto/secrets.yaml \
  --set deployment.image.tag=$VERSION_MOSQUITTO_IMG \
  --namespace mosquitto \
  --create-namespace \
  --install

echo -e "\n\nInstalling influxdb"
echo -e "=========================================================================================="
helm upgrade influxdb influxdata/influxdb2 \
  --version $VERSION_INFLUXDB_HELM \
  --values ./influxdb/values.yaml \
  --namespace influxdb \
  --create-namespace \
  --install

echo -e "\n\nInstalling influxdb-post"
echo -e "=========================================================================================="
helm upgrade influxdb-post ./influxdb-post \
  --values ./influxdb-post/values.yaml \
  --namespace influxdb \
  --create-namespace \
  --install
./influxdb-post/scripts/setup-users.sh

echo -e "\n\nInstalling telegraf"
echo -e "=========================================================================================="
helm upgrade telegraf ./telegraf \
  --version $VERSION_TELEGRAF_HELM \
  --values ./telegraf/values.yaml \
  --namespace telegraf \
  --create-namespace \
  --install

echo -e "\n\nInstalling zigbee2mqtt"
echo -e "=========================================================================================="
helm upgrade zigbee2mqtt ./zigbee2mqtt \
  --values ./zigbee2mqtt/values.yaml \
  --values ./longhorn-post/secrets.yaml \
  --set deployment.image.tag=$VERSION_ZIGBEE2MQTT_IMG \
  --namespace zigbee2mqtt \
  --create-namespace \
  --install

echo -e "\n\nInstalling go2rtc"
echo -e "=========================================================================================="
helm upgrade go2rtc ./go2rtc \
  --values ./go2rtc/values.yaml \
  --values ./go2rtc/secrets.yaml \
  --set deployment.image.tag=$VERSION_GO2RTC_IMG \
  --namespace go2rtc \
  --create-namespace \
  --install

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