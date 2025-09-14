#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1

# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml
# kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml

# helm repo add metallb https://metallb.github.io/metallb
# helm upgrade metallb metallb/metallb \
#   --version 0.15.2 \
#   --values ./metallb/values.yaml \
#   --namespace metallb-system \
#   --create-namespace \
#   --install

helm upgrade metallb-post ./metallb-post \
  --values ./metallb-post/values.yaml \
  --namespace metallb-system \
  --create-namespace \
  --install

helm upgrade cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version v1.18.2 \
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
  --version 37.0.0 \
  --values ./traefik/values.yaml \
  --namespace traefik \
  --create-namespace \
  --install

helm upgrade technitium-dns ./technitium-dns \
  --values ./technitium-dns/values.yaml \
  --namespace technitium-dns \
  --create-namespace \
  --install