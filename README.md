# homelab

## Setup Instructions

### Router Setup
- For each pi, set a static ip
    - 192.168.0.10x
    - This helps with remote config, e.g., when using kubectl and k9s
- Reserve an ip range for MetalLb
    - 192.168.0.2 -> 192.168.0.20
- Setup dns/dhcp on router
    - Should be 192.168.0.10 (statically assigned in k8s/dns config)
    - Create firewall rule (Lan IN) to allow IOT vlan to use 192.168.0.10:53

### Pi Setup
- Base OS
    - Flash sdcard
        - Username / password
            - justinricheson / <pw>
        - Enable ssh
    - Boot and clone to nvme
        - `rpi-clone`
    - Make nvme bootable
    - Set static dns on pi using nmcli
        - 127.0.0.1 1.1.1.1
            - `nmcli device status`
            - `nmcli connection show`
            - `sudo nmcli connection modify "Wired connection 1" ipv4.dns 192.168.0.10`
            - `sudo nmcli connection modify "Wired connection 1" ipv4.ignore-auto-dns yes`
        - Without this, the pi can’t resolve containers before dns is setup
        - Must keep this. Dns deployment uses AlwaysPull latest
        	- A reboot creates a cycle, dns -> k0s -> dns
            - There are ways around this (fallback dns), but rasp pi doesn’t need local dns
- Packages
    - Yum update
        - `sudo apt update`
        - `sudo apt full-upgrade -y`
        - `sudo apt autoremove -y`
        - `sudo reboot`

- K0s
    - Enable cgroups
    - [Install k0s](https://docs.k0sproject.io/stable/install)
    - Disable k0s telemetry
        - `vim /etc/k0s/k0s.yaml`
        - ```yaml
          spec:
			telemetry:
			  enabled: false
          ```
        - `k0s stop & k0s start`
    - Generate Kubeconfig
        - `k0s kubeconfig`
    - If first node
        - Setup MetalLb (see `install.sh`)
    - Else
        - [Join to k0s cluster](https://docs.k0sproject.io/v0.11.0/k0s-multi-node)

- Deployments
    - Push technitium
    - Push home-assistant
    - Push frigate
    	- `KUBECONFIG=~/.kube/config-pi1 kubectl apply -f my-service.yaml` OR
    	- `install.sh`

