#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_CERT_MGR_HELM=v1.20.2 # https://cert-manager.io - curl -s "https://quay.io/api/v1/repository/jetstack/charts/cert-manager/tag/?onlyActiveTags=true&limit=100" | jq -r '.tags[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

echo -e "\n\nInstalling cert-manager"
echo -e "=========================================================================================="
helm upgrade cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version $VERSION_CERT_MGR_HELM \
  --set crds.enabled=true \
  --values "$DIR/values.yaml" \
  --namespace cert-manager \
  --create-namespace \
  --install

echo -e "\n\nInstalling cert-manager-post"
echo -e "=========================================================================================="
helm upgrade cert-manager-post "$DIR/post" \
  --values "$DIR/post/values.yaml" \
  --values "$DIR/post/secrets.yaml" \
  --namespace cert-manager \
  --create-namespace \
  --install