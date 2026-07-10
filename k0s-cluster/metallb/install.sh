#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_METALLB_HELM=0.15.3 # https://metallb.io - helm search repo metallb/metallb --versions | grep -v 'alpha\|beta\|rc' | head -5

helm repo add metallb https://metallb.github.io/metallb

echo -e "\n\nInstalling metallb"
echo -e "=========================================================================================="
helm upgrade metallb metallb/metallb \
  --version $VERSION_METALLB_HELM \
  --values "$DIR/values.yaml" \
  --namespace metallb-system \
  --create-namespace \
  --install

echo -e "\n\nInstalling metallb-post"
echo -e "=========================================================================================="
helm upgrade metallb-post "$DIR/post" \
  --values "$DIR/post/values.yaml" \
  --namespace metallb-system \
  --create-namespace \
  --install