#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_TELEGRAF_HELM=1.8.73 # https://github.com/influxdata/helm-charts - helm search repo influxdata/telegraf --versions | grep -v 'alpha\|beta\|rc' | head -5

helm repo add influxdata https://helm.influxdata.com

echo -e "\n\nInstalling telegraf"
echo -e "=========================================================================================="
"$DIR/scripts/apply-secrets.sh"
helm upgrade telegraf influxdata/telegraf \
  --version $VERSION_TELEGRAF_HELM \
  --values $DIR/values.yaml \
  --namespace telegraf \
  --create-namespace \
  --install