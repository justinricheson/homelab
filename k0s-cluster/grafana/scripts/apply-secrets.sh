#!/bin/bash
set -e

kubectl get secret influxdb-influxdb2-auth -n influxdb -o json \
  | jq 'del(.metadata.namespace, .metadata.uid, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.ownerReferences)' \
  | jq '.metadata.namespace="grafana"' \
  | kubectl apply -f -