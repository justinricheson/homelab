#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1

VERSION_METALLB_HELM=0.15.3   # https://metallb.io                - helm search repo metallb/metallb --versions
VERSION_CERT_MGR_HELM=v1.19.2 # https://cert-manager.io           - https://quay.io/repository/jetstack/charts/cert-manager?tab=tags
VERSION_TRAEFIK_HELM=38.0.1   # https://traefik.io                - helm search repo traefik/traefik --versions
VERSION_LONGHORN_HELM=1.10.1  # https://longhorn.io               - helm search repo longhorn --versions
VERSION_TECHNITIUM_IMG=13.6.0 # https://technitium.com/dns        - https://hub.docker.com/r/technitium/dns-server/tags
VERSION_GO2RTC_IMG=1.9.10     # https://github.com/AlexxIT/go2rtc - https://hub.docker.com/r/alexxit/go2rtc/tags
VERSION_FRIGATE_HELM=7.8.0    # https://frigate.video             - helm search repo blakeblackshear/frigate --versions
VERSION_FRIGATE_IMG=0.16.1    # https://frigate.video             - https://github.com/blakeblackshear/frigate/releases
VERSION_TAILSCALE_IMG=v1.92.4 # https://tailscale.com             - https://hub.docker.com/r/tailscale/tailscale/tags

./scripts/tag-nodes.sh

helm repo update
helm repo add metallb https://metallb.github.io/metallb
helm repo add traefik https://traefik.github.io/charts
helm repo add longhorn https://charts.longhorn.io
helm repo add blakeblackshear https://blakeblackshear.github.io/blakeshome-charts

echo -e "\n\nInstalling metallb"
echo -e "=========================================================================================="
helm upgrade metallb metallb/metallb \
  --version $VERSION_METALLB_HELM \
  --values ./metallb/values.yaml \
  --namespace metallb-system \
  --create-namespace \
  --install

echo -e "\n\nInstalling metallb-post"
echo -e "=========================================================================================="
helm upgrade metallb-post ./metallb-post \
  --values ./metallb-post/values.yaml \
  --namespace metallb-system \
  --create-namespace \
  --install

echo -e "\n\nInstalling cert-manager"
echo -e "=========================================================================================="
helm upgrade cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version $VERSION_CERT_MGR_HELM \
  --set crds.enabled=true \
  --values ./cert-manager/values.yaml \
  --namespace cert-manager \
  --create-namespace \
  --install

echo -e "\n\nInstalling cert-manager-post"
echo -e "=========================================================================================="
helm upgrade cert-manager-post ./cert-manager-post \
  --values ./cert-manager-post/values.yaml \
  --values ./cert-manager-post/secrets.yaml \
  --namespace cert-manager \
  --create-namespace \
  --install

echo -e "\n\nInstalling traefik-prep"
echo -e "=========================================================================================="
helm upgrade traefik-prep ./traefik-prep \
  --values ./traefik-prep/values.yaml \
  --values ./traefik-prep/secrets.yaml \
  --namespace traefik \
  --create-namespace \
  --install

echo -e "\n\nInstalling traefik"
echo -e "=========================================================================================="
helm upgrade traefik traefik/traefik \
  --version $VERSION_TRAEFIK_HELM \
  --values ./traefik/values.yaml \
  --namespace traefik \
  --create-namespace \
  --install

echo -e "\n\nInstalling longhorn"
echo -e "=========================================================================================="
helm upgrade longhorn longhorn/longhorn \
  --version $VERSION_LONGHORN_HELM \
  --values ./longhorn/values.yaml \
  --namespace longhorn-system \
  --create-namespace \
  --install

echo -e "\n\nInstalling longhorn-post"
echo -e "=========================================================================================="
helm upgrade longhorn-post ./longhorn-post \
  --values ./longhorn-post/values.yaml \
  --values ./longhorn-post/secrets.yaml \
  --namespace longhorn-system \
  --create-namespace \
  --install

echo -e "\n\nInstalling technitium-dns"
echo -e "=========================================================================================="
helm upgrade technitium-dns ./technitium-dns \
  --values ./technitium-dns/values.yaml \
  --set deployment.image.tag=$VERSION_TECHNITIUM_IMG \
  --namespace technitium-dns \
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

echo -e "\n\nInstalling tailscale"
echo -e "=========================================================================================="
helm upgrade tailscale ./tailscale \
  --values ./tailscale/values.yaml \
  --values ./tailscale/secrets.yaml \
  --set deployment.image.tag=$VERSION_TAILSCALE_IMG \
  --namespace tailscale \
  --create-namespace \
  --install