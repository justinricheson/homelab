#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_LONGHORN_HELM=1.10.1 # https://longhorn.io - helm search repo longhorn --versions | grep -v 'alpha\|beta\|rc' | head -5

helm repo add longhorn https://charts.longhorn.io

echo -e "\n\nInstalling longhorn"
echo -e "=========================================================================================="
helm upgrade longhorn longhorn/longhorn \
  --version $VERSION_LONGHORN_HELM \
  --values "$DIR/values.yaml" \
  --namespace longhorn-system \
  --create-namespace \
  --install
"$DIR/scripts/tag-longhorn.sh"

echo -e "\n\nInstalling longhorn-post"
echo -e "=========================================================================================="
helm upgrade longhorn-post "$DIR/post" \
  --values "$DIR/post/values.yaml" \
  --values "$DIR/post/secrets.yaml" \
  --namespace longhorn-system \
  --create-namespace \
  --install