#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1

VERSION_METALLB=0.15.2        # https://metallb.io         - helm search repo metallb/metallb --versions
VERSION_CERT_MANAGER=v1.18.2  # https://cert-manager.io    - https://quay.io/repository/jetstack/charts/cert-manager?tab=tags
VERSION_TRAEFIK=37.0.0        # https://traefik.io         - helm search repo traefik/traefik --versions
VERSION_TECHNITIUM=13.6.0     # https://technitium.com/dns - https://hub.docker.com/r/technitium/dns-server/tags

helm repo add metallb https://metallb.github.io/metallb
helm upgrade metallb metallb/metallb \
  --version $VERSION_METALLB \
  --values ./metallb/values.yaml \
  --namespace metallb-system \
  --create-namespace \
  --install

helm upgrade metallb-post ./metallb-post \
  --values ./metallb-post/values.yaml \
  --namespace metallb-system \
  --create-namespace \
  --install

helm upgrade cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version $VERSION_CERT_MANAGER \
  --set crds.enabled=true \
  --values ./cert-manager/values.yaml \
  --namespace cert-manager \
  --create-namespace \
  --install

helm upgrade cert-manager-post ./cert-manager-post \
  --values ./cert-manager-post/values.yaml \
  --values ./cert-manager-post/secrets.yaml \
  --namespace cert-manager \
  --create-namespace \
  --install

helm upgrade traefik-prep ./traefik-prep \
  --values ./traefik-prep/values.yaml \
  --values ./traefik-prep/secrets.yaml \
  --namespace traefik \
  --create-namespace \
  --install

helm repo add traefik https://traefik.github.io/charts
helm upgrade traefik traefik/traefik \
  --version $VERSION_TRAEFIK \
  --values ./traefik/values.yaml \
  --namespace traefik \
  --create-namespace \
  --install

helm upgrade technitium-dns ./technitium-dns \
  --values ./technitium-dns/values.yaml \
  --set deployment.image.tag=$VERSION_TECHNITIUM \
  --namespace technitium-dns \
  --create-namespace \
  --install