# Setup K0s

- Check if cgroups are enabled
  - `sudo cat /proc/cgroups`
  - If not, refer to node-specific instructions
- [Install k0s](https://docs.k0sproject.io/stable/install)
- Make sure all nodes are running the same version
  - `sudo k0s version`
  - If not, see the [upgrade guide](https://docs.k0sproject.io/stable/upgrade)

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