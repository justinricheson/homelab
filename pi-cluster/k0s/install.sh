#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1

# kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml
# kubectl apply -f ip-pool.yaml

helm upgrade cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --install \
  --create-namespace \
  --namespace cert-manager \
  --version v1.18.2 \
  --set crds.enabled=true \
  --values ./cert-manager/values.yaml

helm upgrade cert-manager-post ./cert-manager-post \
  --install \
  --namespace cert-manager \
  --values ./cert-manager-post/values.yaml \
  --values ./cert-manager-post/secrets.yaml

helm upgrade traefik-prep ./traefik-prep \
  --install \
  --namespace traefik \
  --values ./traefik-prep/values.yaml \
  --values ./traefik-prep/secrets.yaml

helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade traefik traefik/traefik \
  --install \
  --namespace traefik \
  --version 37.0.0 \
  --values ./traefik/values.yaml

helm upgrade technitium-dns ./technitium-dns \
  --install \
  --namespace technitium-dns \
  --values ./technitium-dns/values.yaml