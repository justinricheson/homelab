#!/bin/bash

set -e

read -rsp "Enter the aws access key id: " ACCESS_KEY_ID
echo

read -rsp "Enter the aws secret access key: " SECRET_ACCESS_KEY
echo

read -rsp "Enter the traefik admin password: " ADMIN_PASSWORD
echo

export KUBECONFIG=~/.kube/config-pi1

kubectl create namespace cert-manager
kubectl create secret generic route53-credentials-secret \
  --from-literal=access-key-id="$ACCESS_KEY_ID" \
  --from-literal=secret-access-key="$SECRET_ACCESS_KEY" \
  -n cert-manager

HASHED=$(htpasswd -nbB admin "$ADMIN_PASSWORD" | cut -d ':' -f2-)
kubectl create namespace traefik
kubectl create secret generic traefik-auth-secret \
  --from-literal=users="admin:$HASHED" \
  -n traefik

unset ACCESS_KEY_ID
unset SECRET_ACCESS_KEY
unset ADMIN_PASSWORD
unset HASHED

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml
kubectl apply -f ip-pool.yaml

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl apply -f cert-issuer.yaml

kubectl apply -f traefik.yaml
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik \
  --namespace traefik \
  --values traefik-values.yaml

kubectl apply -f technitium-dns.yaml