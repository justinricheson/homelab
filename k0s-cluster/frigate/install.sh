#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_FRIGATE_HELM=7.8.0 # https://frigate.video - helm search repo blakeblackshear/frigate --versions | grep -v 'alpha\|beta\|rc' | head -5
VERSION_FRIGATE_IMG=0.17.1 # https://frigate.video - curl -s "https://api.github.com/repos/blakeblackshear/frigate/releases/latest" | jq -r '.tag_name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

helm repo add blakeblackshear https://blakeblackshear.github.io/blakeshome-charts

echo -e "\n\nInstalling frigate-prep"
echo -e "=========================================================================================="
helm upgrade frigate-prep "$DIR/prep" \
  --values "$DIR/prep/values.yaml" \
  --namespace frigate \
  --create-namespace \
  --install

echo -e "\n\nInstalling frigate"
echo -e "=========================================================================================="
helm upgrade frigate blakeblackshear/frigate \
  --version $VERSION_FRIGATE_HELM \
  --values "$DIR/values.yaml" \
  --set image.tag=$VERSION_FRIGATE_IMG \
  --namespace frigate \
  --create-namespace \
  --install
"$DIR/scripts/patch-service-port-name.sh"

echo -e "\n\nInstalling frigate-post"
echo -e "=========================================================================================="
helm upgrade frigate-post "$DIR/post" \
  --values "$DIR/post/values.yaml" \
  --namespace frigate \
  --create-namespace \
  --install