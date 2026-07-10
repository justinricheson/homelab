#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_KYVERNO_HELM=3.8.1 # https://github.com/kyverno/kyverno - helm search repo kyverno/kyverno --versions | grep -v 'alpha\|beta\|rc' | head -5

helm repo add kyverno https://kyverno.github.io/kyverno

echo -e "\n\nInstalling kyverno"
echo -e "=========================================================================================="
helm upgrade kyverno kyverno/kyverno \
  --version $VERSION_KYVERNO_HELM \
  --values "$DIR/values.yaml" \
  --namespace kyverno \
  --create-namespace \
  --install

echo -e "\n\nInstalling kyverno-post"
echo -e "=========================================================================================="
helm upgrade kyverno-post "$DIR/post" \
  --values "$DIR/post/values.yaml" \
  --namespace kyverno \
  --create-namespace \
  --install