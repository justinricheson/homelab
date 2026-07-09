#!/bin/sh
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="influxdb"

# Users and their secrets.env var names (parallel lists, POSIX-safe)
USERS="admin"
PASS_VAR_admin="ADMIN_PASS"

. "$DIR/secrets.env"

POD=$(kubectl get pod -n "$NAMESPACE" -l app.kubernetes.io/name=influxdb2 -o jsonpath='{.items[0].metadata.name}')
INFLUX_TOKEN=$(kubectl get secret influxdb-influxdb2-auth -n influxdb -o jsonpath='{.data.admin-token}' | base64 -d)

if [ -z "$POD" ]; then
  echo "Could not find InfluxDB pod. Labels in namespace '$NAMESPACE':"
  kubectl get pods -n "$NAMESPACE" --show-labels
  exit 1
fi

echo "Using pod: $POD"

for USER in $USERS; do
  eval "PASS_VAR=\$PASS_VAR_$USER"
  eval "PASS=\$$PASS_VAR"

  if kubectl exec -n "$NAMESPACE" "$POD" -- influx user list -t "$INFLUX_TOKEN" | awk '{print $2}' | grep -qx "$USER"; then
    echo "User '$USER' already exists, skipping creation."
  else
    echo "Creating user '$USER'..."
    kubectl exec -n "$NAMESPACE" "$POD" -- influx user create --name "$USER" -t "$INFLUX_TOKEN"
  fi

  echo "Setting password for '$USER'..."
  kubectl exec -n "$NAMESPACE" "$POD" -- influx user password -n "$USER" -p "$PASS" -t "$INFLUX_TOKEN"
done