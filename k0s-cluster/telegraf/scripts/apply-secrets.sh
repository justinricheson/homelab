#!/bin/bash
set -e

INFLUX_TOKEN=$(kubectl get secret influxdb-influxdb2-auth -n influxdb -o jsonpath='{.data.admin-token}' | base64 -d)

kubectl create secret generic telegraf-secrets \
  --from-literal=INFLUX_TOKEN="$INFLUX_TOKEN" \
  --namespace telegraf \
  --dry-run=client -o yaml | kubectl apply -f -