# homelab

## Setup Instructions

### Router Setup

- Reserve an ip range for MetalLb
  - 192.168.0.2 -> 192.168.0.20
- Setup dhcp on router
  - Point DNS to 192.168.0.10 (statically assigned in technitium config)
  - Create firewall rules for IOT vlan
    - Allow any -> 192.168.0.10:53
    - Allow any -> Default vlan (established/related)
    - Allow any -> internet
    - Deny any -> any

### Pi Setup

- Base OS
  - [Flash sdcard](https://www.raspberrypi.com/software)
    - Hostname: pi<num>
    - Username / password
    - Enable ssh
  - Boot and clone sdcard to nvme
    - [rpi-clone](https://github.com/geerlingguy/rpi-clone)
    - Install:
      - `git clone https://github.com/geerlingguy/rpi-clone.git`
      - `cd rpi-clone && sudo cp rpi-clone rpi-clone-setup /usr/local/sbin`
    - Clone: `sudo rpi-clone /dev/nvme0n1`
      - Leave the optional filesystem label empty
    - `sudo shutdown -h now`
    - Remove sdcard, and reboot
    - Cleanup rpi-clone:
      - `sudo rm /usr/local/sbin/rpi-clone`
      - `sudo rm /usr/local/sbin/rpi-clone-setup`
  - Set static dns on pi using nmcli
    - `nmcli device status`
    - `nmcli connection show`
    - `sudo nmcli connection modify "Wired connection 1" ipv4.dns 1.1.1.1`
    - `sudo nmcli connection modify "Wired connection 1" ipv4.ignore-auto-dns yes`
    - `sudo reboot`
    - Without this, the pi can’t resolve containers before dns is setup. Since dns deployment runs on k0s, a reboot creates a cycle, dns -> k0s -> dns.
- Packages
  - Update raspi-config
    - `sudo raspi-config`
    - `update`
    - `sudo reboot`
  - Set wifi country
    - `sudo raspi-config`
    - `Localization Options > WLAN Country`
    - `sudo reboot`
  - Yum update
    - `sudo apt update`
    - `sudo apt full-upgrade -y`
    - `sudo apt autoremove -y`
    - `sudo reboot`
  - Setup iscsi (for longhorn)
    - `sudo apt-get install -y open-iscsi`
    - `sudo reboot`
    - `sudo systemctl enable iscsid`
    - `sudo systemctl start iscsid`

- K0s
  - Enable cgroups
    - `sudo nano /boot/firmware/cmdline.txt`
    - Add this to the end of the line: ` cgroup_memory=1 cgroup_enable=memory`
  - [Install k0s](https://docs.k0sproject.io/stable/install)
    - Make sure all nodes are running the same version
      - `sudo k0s version`
      - If not, see the [upgrade guide](https://docs.k0sproject.io/stable/upgrade)
    - `curl --proto '=https' --tlsv1.2 -sSf https://get.k0s.sh | sudo sh`
    - On pi1:
      - `sudo k0s install controller --enable-worker --no-taints`
      - `sudo k0s start`
    - On others:
      - `ssh pi1.local`
      - `sudo k0s token create --role=worker --expiry=100h`
      - `ssh pi2.local`
      - `sudo mkdir /etc/k0s`
      - `sudo touch /etc/k0s/token-file` Copy the token here
      - `sudo chown root:root /etc/k0s/token-file`
      - `sudo chmod 644 /etc/k0s/token-file`
      - `sudo k0s install worker --token-file /etc/k0s/token-file`
      - `sudo k0s start`
    - `sudo k0s status`
  - Disable k0s telemetry, and setup sans
    - `sudo nano /etc/k0s/k0s.yaml`
    - ```yaml
      spec:
      api:
        sans:
        - pi1.local # Only include on pi1
      telemetry:
        enabled: false
      ```
    - `sudo k0s stop & k0s start`
  - Generate Kubeconfig
    - `sudo k0s kubeconfig admin`
    - Change the ip address in this file to pi1.local (in case ip changes)

- Deployments
  - Push technitium, etc
    - `install.sh`
      - Note: on this error, try again. Sometimes the webhook takes a few seconds to install.
        - ```bash
        * Internal error occurred: failed calling webhook "ipaddresspoolvalidationwebhook.metallb.io": failed to call webhook: Post "https://metallb-webhook-service.metallb-system.svc:443/validate-metallb-io-v1beta1-ipaddresspool?timeout=10s": dial tcp 10.101.89.12:443: i/o timeout
        ```
  - Setup users
    - technitium
    - frigate
  - Restore settings
    - technitium