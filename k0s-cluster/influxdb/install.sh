#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1
DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_INFLUXDB_HELM=2.1.2 # https://www.influxdata.com/products/influxdb - helm search repo influxdata/influxdb2 --versions | grep -v 'alpha\|beta\|rc' | head -5

helm repo add influxdata https://helm.influxdata.com

echo -e "\n\nInstalling influxdb"
echo -e "=========================================================================================="
helm upgrade influxdb influxdata/influxdb2 \
  --version $VERSION_INFLUXDB_HELM \
  --values "$DIR/values.yaml" \
  --namespace influxdb \
  --create-namespace \
  --install

echo -e "\n\nInstalling influxdb-post"
echo -e "=========================================================================================="
helm upgrade influxdb-post "$DIR/post" \
  --values "$DIR/post/values.yaml" \
  --namespace influxdb \
  --create-namespace \
  --install
"$DIR/post/scripts/setup-users.sh"