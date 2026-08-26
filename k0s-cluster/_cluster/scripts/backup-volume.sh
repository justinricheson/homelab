#!/bin/bash
set -e

# ---- CONFIG ----
NAMESPACE="frigate"
PVC_NAME="frigate-media"
LOCAL_BACKUP_DIR="$HOME/Documents-nobak/local-backup/$PVC_NAME"
LOCAL_PORT="8873"
# ----------------

TMP_POD="tmp-backup-$(date +%s)"

kubectl run "$TMP_POD" --image=eeacms/rsync --restart=Never -n "$NAMESPACE" \
  --overrides='{
    "spec": {
      "containers": [{
        "name": "tmp-backup",
        "image": "eeacms/rsync",
        "command": ["sh", "-c", "echo \"[data]\npath = /data\nread only = true\nuse chroot = false\" > /etc/rsyncd.conf && rsync --daemon --no-detach --config=/etc/rsyncd.conf --port=873"],
        "ports": [{"containerPort": 873}],
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

echo "Port-forwarding..."
kubectl port-forward -n "$NAMESPACE" pod/"$TMP_POD" "$LOCAL_PORT":873 &
PF_PID=$!
sleep 3

mkdir -p "$LOCAL_BACKUP_DIR"

rsync -avh --progress rsync://localhost:"$LOCAL_PORT"/data/ "$LOCAL_BACKUP_DIR"/

echo "Backup complete: $LOCAL_BACKUP_DIR"

kill "$PF_PID"
kubectl delete pod "$TMP_POD" -n "$NAMESPACE"