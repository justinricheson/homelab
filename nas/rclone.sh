#!/bin/sh
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
CRON_JOB="0 2 * * * $DIR/rclone.sh >> $DIR/rclone.log 2>&1"
if [ "$1" == "cron" ]; then
  # Clear:   echo "" | sudo tee /usr/builtin/etc/crontabs/root
  # Check:   cat /usr/builtin/etc/crontabs/root
  # Restart: sudo /etc/init.d/S41crond restart

  # Clear dupes
  grep -v rclone.sh /usr/builtin/etc/crontabs/root 2>/dev/null | sudo tee /usr/builtin/etc/crontabs/root > /dev/null
  echo "$CRON_JOB" | sudo tee -a /usr/builtin/etc/crontabs/root > /dev/null
  sudo /etc/init.d/S41crond restart
  echo "Installed cron job: $CRON_JOB"
  exit 0
fi

CAFILE="/etc/ssl/certs/ca-certificates.crt"
MQTT_HOST="mqtt.home.justinricheson.com"
MQTT_PORT="8883"
MQTT_TOPIC="nas/rclone/status"
MQTT_USER="iot"
#MQTT_PASS=Put in secrets.env

publish() {
  /opt/bin/mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" --cafile "$CAFILE" \
    -u "$MQTT_USER" -P "$MQTT_PASS" -t "$MQTT_TOPIC" -m "$1" -r
  echo "$1"
}

. "$DIR/secrets.env"
if [ "$1" = "mqtt" ]; then
  publish '{"status":"success","time":"'"$(date -u +%FT%TZ)"'"}'
  exit 0
fi

export RCLONE_SOURCE="/volume1/backup"
export RCLONE_REMOTE="remote:nas-backup-790055257995-us-east-1-an/backup"
export RCLONE_CONFIG_REMOTE_TYPE=s3
export RCLONE_CONFIG_REMOTE_REGION=us-east-1
#export RCLONE_CONFIG_REMOTE_ACCESS_KEY_ID=Put in secrets.env
#export RCLONE_CONFIG_REMOTE_SECRET_ACCESS_KEY=Put in secrets.env

publish '{"status":"start","time":"'"$(date -u +%FT%TZ)"'"}'
if /opt/bin/rclone sync "$RCLONE_SOURCE" "$RCLONE_REMOTE" --fast-list --log-level ERROR; then
  publish '{"status":"success","time":"'"$(date -u +%FT%TZ)"'"}'
else
  publish '{"status":"failure","time":"'"$(date -u +%FT%TZ)"'"}'
fi