#!/bin/sh
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
CRON_JOB="0 2 * * * $DIR/rclone.sh run"

if [ "$1" != "run" ]; then
  ( sudo crontab -l 2>/dev/null | grep -v "$(basename "$0")" ; echo "$CRON_JOB" ) | sudo crontab -
  echo "Installed cron job: $CRON_JOB"
  exit 0
fi

CAFILE="/etc/ssl/certs/ca-certificates.crt"
MQTT_HOST="mqtt.home.justinricheson.com"
MQTT_PORT="8883"
MQTT_TOPIC="nas/rclone/status"
MQTT_USER="iot"
#MQTT_PASS=Put in secrets.env

RCLONE_SOURCE="/volume1/backup"
RCLONE_REMOTE="remote:nas-backup-790055257995-us-east-1-an/backup"
export RCLONE_CONFIG_REMOTE_TYPE=s3
export RCLONE_CONFIG_REMOTE_REGION=us-east-1
#export RCLONE_CONFIG_REMOTE_ACCESS_KEY_ID=Put in secrets.env
#export RCLONE_CONFIG_REMOTE_SECRET_ACCESS_KEY=Put in secrets.env

publish() {
  mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" --cafile "$CAFILE" \
    -u "$MQTT_USER" -P "$MQTT_PASS" -t "$MQTT_TOPIC" -m "$1" -r
}

. "$DIR/secrets.env"

if rclone sync "$RCLONE_SOURCE" "$RCLONE_REMOTE" --log-level ERROR; then
  publish '{"status":"success","time":"'"$(date -u +%FT%TZ)"'"}'
else
  publish '{"status":"failure","time":"'"$(date -u +%FT%TZ)"'"}'
fi