#!/bin/bash

set -e

export KUBECONFIG=~/.kube/config-pi1

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml
kubectl apply -f ip-pool.yaml

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl apply -f cert-issuer.yaml

if helm status cert-manager-prep -n cert-manager >/dev/null 2>&1; then
  helm upgrade cert-manager-prep ./cert-manager-prep \
    --namespace cert-manager \
    --values ./cert-manager-prep/values.yaml \
    --values ./cert-manager-prep/secrets.yaml
else
  helm install cert-manager-prep ./cert-manager-prep \
    --create-namespace \
    --namespace cert-manager \
    --values ./cert-manager-prep/values.yaml \
    --values ./cert-manager-prep/secrets.yaml
fi

if helm status traefik-prep -n traefik >/dev/null 2>&1; then
  helm upgrade traefik-prep ./traefik-prep \
    --namespace traefik \
    --values ./traefik-prep/values.yaml \
    --values ./traefik-prep/secrets.yaml
else
  helm install traefik-prep ./traefik-prep \
    --create-namespace \
    --namespace traefik \
    --values ./traefik-prep/values.yaml \
    --values ./traefik-prep/secrets.yaml
fi

kubectl apply -f traefik.yaml
helm repo add traefik https://traefik.github.io/charts
helm repo update
if helm status traefik -n traefik >/dev/null 2>&1; then
  helm upgrade traefik traefik/traefik \
    --namespace traefik \
    --version 37.0.0 \
    --values ./traefik/values.yaml
else
  helm install traefik traefik/traefik \
    --namespace traefik \
    --version 37.0.0 \
    --values ./traefik/values.yaml
fi

if helm status technitium-dns -n technitium-dns >/dev/null 2>&1; then
  helm upgrade technitium-dns ./technitium-dns \
    --namespace technitium-dns \
    --values ./technitium-dns/values.yaml
else
  helm install technitium-dns ./technitium-dns \
    --create-namespace \
    --namespace technitium-dns \
    --values ./technitium-dns/values.yaml
fi