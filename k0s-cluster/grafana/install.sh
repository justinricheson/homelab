#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_GRAFANA_HELM=14.0.1 # https://github.com/grafana-community/helm-charts - helm search repo grafana-community/grafana --versions | head -5

helm repo add grafana-community https://grafana-community.github.io/helm-charts

echo -e "\n\nInstalling grafana-prep"
echo -e "=========================================================================================="
helm upgrade grafana-prep "$DIR/prep" \
  --values "$DIR/prep/values.yaml" \
  --values "$DIR/prep/secrets.yaml" \
  --namespace grafana \
  --create-namespace \
  --install

echo -e "\n\nInstalling grafana"
echo -e "=========================================================================================="
"$DIR/scripts/apply-secrets.sh"
helm upgrade grafana grafana-community/grafana \
  --version $VERSION_GRAFANA_HELM \
  --values "$DIR/values.yaml" \
  --namespace grafana \
  --create-namespace \
  --install

echo -e "\n\nInstalling grafana-post"
echo -e "=========================================================================================="
helm upgrade grafana-post "$DIR/post" \
  --values "$DIR/post/values.yaml" \
  --namespace grafana \
  --create-namespace \
  --install
