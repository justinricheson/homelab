#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_GRAFANA_HELM=10.5.15 # https://grafana.com - helm search repo grafana/grafana --versions | grep -v 'alpha\|beta\|rc' | head -5

helm repo add grafana https://grafana.github.io/helm-charts

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
helm upgrade grafana grafana/grafana \
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