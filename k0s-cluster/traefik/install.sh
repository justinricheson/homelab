#!/bin/bash

set -e

KUBECONFIG=~/.kube/config-pi1
DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_TRAEFIK_HELM=41.0.1 # https://traefik.io - helm search repo traefik/traefik --versions | grep -v 'alpha\|beta\|rc' | head -5

helm repo add traefik https://traefik.github.io/charts

echo -e "\n\nInstalling traefik-prep"
echo -e "=========================================================================================="
helm upgrade traefik-prep "$DIR/prep" \
  --values "$DIR/prep/values.yaml" \
  --values "$DIR/prep/secrets.yaml" \
  --namespace traefik \
  --create-namespace \
  --install

echo -e "\n\nInstalling traefik"
echo -e "=========================================================================================="
helm upgrade traefik traefik/traefik \
  --version $VERSION_TRAEFIK_HELM \
  --values "$DIR/values.yaml" \
  --namespace traefik \
  --create-namespace \
  --install
# Uncomment to reinstall crds. Check https://github.com/traefik/traefik-helm-chart for the current version
#kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml

echo -e "\n\nInstalling traefik-post"
echo -e "=========================================================================================="
helm upgrade traefik-post "$DIR/post" \
  --values "$DIR/post/values.yaml" \
  --namespace traefik \
  --create-namespace \
  --install