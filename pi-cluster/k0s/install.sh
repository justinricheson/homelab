#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1

VERSION_METALLB=0.15.2        # https://metallb.io                - helm search repo metallb/metallb --versions
VERSION_CERT_MANAGER=v1.18.2  # https://cert-manager.io           - https://quay.io/repository/jetstack/charts/cert-manager?tab=tags
VERSION_TRAEFIK=37.0.0        # https://traefik.io                - helm search repo traefik/traefik --versions
VERSION_LONGHORN=1.9.1        # https://longhorn.io               - helm search repo longhorn --versions
VERSION_TECHNITIUM=13.6.0     # https://technitium.com/dns        - https://hub.docker.com/r/technitium/dns-server/tags
VERSION_GO2RTC=1.9.10         # https://github.com/AlexxIT/go2rtc - https://hub.docker.com/r/alexxit/go2rtc/tags
VERSION_FRIGATE=7.8.0         # https://frigate.video             - https://blakeblackshear.github.io/blakeshome-charts

helm repo update
helm repo add metallb https://metallb.github.io/metallb
helm repo add traefik https://traefik.github.io/charts
helm repo add longhorn https://charts.longhorn.io
helm repo add blakeblackshear https://blakeblackshear.github.io/blakeshome-charts

echo -e "\n\nInstalling metallb"
echo -e "=========================================================================================="
helm upgrade metallb metallb/metallb \
  --version $VERSION_METALLB \
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
  --version $VERSION_CERT_MANAGER \
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
  --version $VERSION_TRAEFIK \
  --values ./traefik/values.yaml \
  --namespace traefik \
  --create-namespace \
  --install

echo -e "\n\nInstalling longhorn"
echo -e "=========================================================================================="
helm upgrade longhorn longhorn/longhorn \
  --version $VERSION_LONGHORN \
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
  --set deployment.image.tag=$VERSION_TECHNITIUM \
  --namespace technitium-dns \
  --create-namespace \
  --install

echo -e "\n\nInstalling go2rtc"
echo -e "=========================================================================================="
helm upgrade go2rtc ./go2rtc \
  --values ./go2rtc/values.yaml \
  --values ./go2rtc/secrets.yaml \
  --set deployment.image.tag=$VERSION_GO2RTC \
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
  --version $VERSION_FRIGATE \
  --values ./frigate/values.yaml \
  --namespace frigate \
  --create-namespace \
  --install

echo -e "\n\nInstalling frigate-post"
echo -e "=========================================================================================="
helm upgrade frigate-post ./frigate-post \
  --values ./frigate-post/values.yaml \
  --values ./frigate-post/secrets.yaml \
  --namespace frigate \
  --create-namespace \
  --install