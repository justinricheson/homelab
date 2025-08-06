export KUBECONFIG=~/.kube/config-pi1

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml

kubectl apply -f ip-pool.yaml

kubectl apply -f technitium-dns.yaml