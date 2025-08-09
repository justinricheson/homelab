# homelab

## Setup Instructions

### Router Setup

- Reserve an ip range for MetalLb
  - 192.168.0.2 -> 192.168.0.20
- Setup dns/dhcp on router
  - Should be 192.168.0.10 (statically assigned in k8s/dns config)
  - Create firewall rule (Lan IN) to allow IOT vlan to use 192.168.0.10:53

### Pi Setup

- Base OS
  - Flash sdcard
    - Username / password
    - Enable ssh
  - Boot and clone to nvme
    - [rpi-clone](https://github.com/geerlingguy/rpi-clone)
  - Make nvme bootable
  - Set static dns on pi using nmcli
    - `nmcli device status`
    - `nmcli connection show`
    - `sudo nmcli connection modify "Wired connection 1" ipv4.dns 1.1.1.1`
    - `sudo nmcli connection modify "Wired connection 1" ipv4.ignore-auto-dns yes`
    - Without this, the pi can’t resolve containers before dns is setup. Since dns deployment uses AlwaysPull latest, a reboot creates a cycle, dns -> k0s -> dns. There are ways around this (fallback dns), but this is simple and rasp pi doesn’t need local dns.
- Packages
  - Yum update
    - `sudo apt update`
    - `sudo apt full-upgrade -y`
    - `sudo apt autoremove -y`
    - `sudo reboot`

- K0s
  - Enable cgroups
  - [Install k0s](https://docs.k0sproject.io/stable/install)
  - Disable k0s telemetry, and setup sans
    - `vim /etc/k0s/k0s.yaml`
    - ```yaml
      spec:
      api:
        sans:
        - pi1.local
      telemetry:
        enabled: false
      ```
    - `k0s stop & k0s start`
  - Generate Kubeconfig
    - `k0s kubeconfig admin`
    - Change the ip address in this file to pi1.local (in case ip changes)
  - If first node
    - Setup MetalLb (see `install.sh`)
  - Else
    - [Join to k0s cluster](https://docs.k0sproject.io/v0.11.0/k0s-multi-node)

- Deployments
  - Push technitium, etc
    - `install.sh`
  - Restore technitium settings