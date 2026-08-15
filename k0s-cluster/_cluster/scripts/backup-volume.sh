#!/bin/bash
set -e

# ---- CONFIG ----
NAMESPACE="home-assistant"
PVC_NAME="home-assistant-pvc"
LOCAL_BACKUP_DIR="$HOME/Documents-nobak/local-backup/$PVC_NAME"
# ----------------

TMP_POD="tmp-backup-$(date +%s)"

kubectl run "$TMP_POD" --image=busybox --restart=Never -n "$NAMESPACE" \
  --overrides='{
    "spec": {
      "containers": [{
        "name": "tmp-backup",
        "image": "busybox",
        "command": ["sleep", "3600"],
        "volumeMounts": [{"mountPath": "/data", "name": "vol"}]
      }],
      "volumes": [{
        "name": "vol",
        "persistentVolumeClaim": {"claimName": "'"$PVC_NAME"'"}
      }]
    }
  }'

echo "Waiting for pod to be ready..."
kubectl wait --for=condition=Ready pod/"$TMP_POD" -n "$NAMESPACE" --timeout=60s

mkdir -p "$LOCAL_BACKUP_DIR"
kubectl cp "$NAMESPACE/$TMP_POD:/data" "$LOCAL_BACKUP_DIR"

echo "Backup complete: $LOCAL_BACKUP_DIR"

kubectl delete pod "$TMP_POD" -n "$NAMESPACE"