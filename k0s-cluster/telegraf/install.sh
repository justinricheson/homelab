#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_TELEGRAF_HELM=1.8.78 # https://github.com/influxdata/helm-charts - helm search repo influxdata/telegraf --versions | grep -v 'alpha\|beta\|rc' | head -5
VERSION_TELEGRAF_IMG=1.40.2-alpine # https://hub.docker.com/_/telegraf - curl -s "https://hub.docker.com/v2/repositories/library/telegraf/tags?page_size=100" | jq -r '.results[].name' | grep -E '^1\.[0-9]+\.[0-9]+-alpine$' | sort -V | tail -5

helm repo add influxdata https://helm.influxdata.com

echo -e "\n\nInstalling telegraf"
echo -e "=========================================================================================="
"$DIR/scripts/apply-secrets.sh"
helm upgrade telegraf influxdata/telegraf \
  --version $VERSION_TELEGRAF_HELM \
  --set image.tag=$VERSION_TELEGRAF_IMG \
  --values $DIR/values.yaml \
  --namespace telegraf \
  --create-namespace \
  --install
