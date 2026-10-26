#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_INFLUXDB_HELM=2.1.2 # https://www.influxdata.com/products/influxdb - helm search repo influxdata/influxdb2 --versions | grep -v 'alpha\|beta\|rc' | head -5
VERSION_INFLUXDB_IMG=2.9.1-alpine # https://hub.docker.com/_/influxdb - curl -s "https://hub.docker.com/v2/repositories/library/influxdb/tags?page_size=100" | jq -r '.results[].name' | grep -E '^2\.[0-9]+\.[0-9]+-alpine$' | sort -V | tail -5

helm repo add influxdata https://helm.influxdata.com

echo -e "\n\nInstalling influxdb"
echo -e "=========================================================================================="
helm upgrade influxdb influxdata/influxdb2 \
  --version $VERSION_INFLUXDB_HELM \
  --set image.tag="$VERSION_INFLUXDB_IMG" \
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
