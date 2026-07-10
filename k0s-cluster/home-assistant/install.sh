#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_HA_HELM=0.3.63 # https://github.com/pajikos/home-assistant-helm-chart - helm search repo pajikos/home-assistant --versions | grep -v 'alpha\|beta\|rc' | head -5

helm repo add pajikos http://pajikos.github.io/home-assistant-helm-chart

echo -e "\n\nInstalling home-assistant-prep"
echo -e "=========================================================================================="
kubectl delete job home-assistant-config-init -n home-assistant
helm upgrade home-assistant-prep "$DIR/prep" \
  --values "$DIR/prep/values.yaml" \
  --namespace home-assistant \
  --create-namespace \
  --install

echo -e "\n\nInstalling home-assistant"
echo -e "=========================================================================================="
helm upgrade home-assistant pajikos/home-assistant \
  --version $VERSION_HA_HELM \
  --values "$DIR/values.yaml" \
  --namespace home-assistant \
  --create-namespace \
  --install