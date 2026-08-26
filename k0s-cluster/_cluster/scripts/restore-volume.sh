#!/bin/bash
set -e

# ---- CONFIG ----
NAMESPACE="frigate"
PVC_NAME="frigate-media"
LOCAL_BACKUP_DIR="$HOME/Documents-nobak/local-backup/$PVC_NAME"
LOCAL_PORT="8874"
# ----------------

TMP_POD="tmp-restore-$(date +%s)"

kubectl run "$TMP_POD" --image=eeacms/rsync --restart=Never -n "$NAMESPACE" \
  --overrides='{
    "spec": {
      "containers": [{
        "name": "tmp-restore",
        "image": "eeacms/rsync",
        "securityContext": {
          "runAsUser": 0,
          "runAsGroup": 0
        },
        "command": ["sh", "-c", "chmod 777 /data; echo \"[data]\npath = /data\nread only = false\nuse chroot = false\" > /etc/rsyncd.conf && rsync --daemon --no-detach --config=/etc/rsyncd.conf --port=873"],
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

rsync -avh --progress \
  --exclude='.DS_Store' \
  --exclude='._*' \
  "$LOCAL_BACKUP_DIR"/ rsync://localhost:"$LOCAL_PORT"/data/

echo "Restore complete into PVC: $PVC_NAME"

kill "$PF_PID"
kubectl delete pod "$TMP_POD" -n "$NAMESPACE"
