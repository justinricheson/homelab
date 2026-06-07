# Setup K0s

- Check if cgroups are enabled
  - `sudo cat /proc/cgroups`
  - If not, refer to node-specific instructions
- [Install k0s](https://docs.k0sproject.io/stable/install)
- Make sure all nodes are running the same version
  - `sudo k0s version`
  - If not, see the [Maintenance](#Maintenance) section

# Controller

- Install controller
  - `sudo k0s install controller --enable-worker --no-taints`
  - `sudo k0s start`

- Config
  - `sudo nano /etc/k0s/k0s.yaml`
    ```yaml
    spec:
      api:
        sans:
        - <controller>.local # Only include on controller
      telemetry:
        enabled: false
    ```
  - `sudo k0s stop & sudo k0s start`

- Generate Kubeconfig
  - `sudo k0s kubeconfig admin`
  - Change the ip address in this file to <controller>.local (in case ip changes)

# Workers

- Install worker
  - `ssh <controller>.local`
  - `sudo k0s token create --role=worker --expiry=100h`
  - `ssh <worker>.local`
  - `sudo mkdir /etc/k0s`
  - `sudo touch /etc/k0s/token-file` Copy the token here
  - `sudo chown root:root /etc/k0s/token-file`
  - `sudo chmod 644 /etc/k0s/token-file`
  - `sudo k0s install worker --token-file /etc/k0s/token-file`
  - `sudo k0s start`
  - `sudo k0s status`

- Config
  - `sudo nano /etc/k0s/k0s.yaml`
    ```yaml
    spec:
      telemetry:
        enabled: false
    ```
  - `sudo k0s stop & sudo k0s start`

# Maintenance

- Create `k0sctl` user and key
  - Generate a key pair: `ssh-keygen -t ed25519 -f ~/.ssh/k0s_cluster -C "k0s cluster"`
  - SSH into each node and run:
    ```bash
    sudo useradd -m -s /bin/bash k0s && sudo passwd k0s
    echo "k0s ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/k0s
    ```
  - Copy the key to all nodes: `ssh-copy-id -i ~/.ssh/k0s_cluster.pub k0s@<node>.local`

- Install `k0sctl`
  - `brew install k0sproject/tap/k0sctl`

- Setup `k0sctl`
  - If the ips have changed you may need to update the config
  - Ping each node: `ping <node.local`
  - Collect the IPs and update the config
    - `address: 10.10.145.8`

- Backup
  - `k0sctl backup --config ~/<path-to-workspace>/_cluster/k0sctl.yaml`

- Upgrade
  - `k0sctl apply --config ~/<path-to-workspace>/_cluster/k0sctl.yaml`