#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION_GO2RTC_IMG=1.9.14 # https://github.com/AlexxIT/go2rtc - curl -s "https://hub.docker.com/v2/repositories/alexxit/go2rtc/tags/?page_size=100" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -5

echo -e "\n\nInstalling go2rtc"
echo -e "=========================================================================================="
helm upgrade go2rtc "$DIR" \
  --values "$DIR/values.yaml" \
  --values "$DIR/secrets.yaml" \
  --set deployment.image.tag=$VERSION_GO2RTC_IMG \
  --namespace go2rtc \
  --create-namespace \
  --install