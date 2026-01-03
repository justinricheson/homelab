# Base Node Setup for Beelink EQi12

- BIOS
  - Configure system to reboot on power failure
    - Chipset > PCH-IO Configuration
    - State after G3: S0 State

- OS
  - Flash usb drive with image
    - [Debian base image](https://www.debian.org/distrib/netinst)
    - `brew install balenaetcher`
  - Install image
    - `F7` for boot menu > `UEFI: General USB Flash Disk`
    - Select `Graphical Install`
    - Hostname: `bl<num>`
    - Domain: `justinricheson.com`
    - Skip the root password screen
    - Setup username / password for non-root user
    - Select `Guided - use entire disk` on the disk setup screen
    - Select `All files in one partition`
    - On the `Software selection` screen
      - Uncheck `Debian desktop environment`
      - Uncheck `GNOME`
      - Check `SSH server`
      - Check `standard system utilities`

- Packages
  - Yum update
    - `sudo apt update`
    - `sudo apt full-upgrade -y`
    - `sudo apt autoremove -y`
    - `sudo reboot`
  - Setup iscsi (for longhorn)
    - `sudo apt install -y open-iscsi`
    - `sudo reboot`
    - `sudo systemctl enable iscsid`
    - `sudo systemctl start iscsid`
  - Setup avahi-daemon (for mDNS)
    - `sudo apt install -y avahi-daemon avahi-utils`
    - `sudo reboot`
    - `sudo systemctl enable avahi-daemon`
    - `sudo systemctl start avahi-daemon`
  - Setup systemd-resolvd
    - Debian is weird and doesn't install this out of the box. It's needed to set dns from dhcp.
    - `sudo apt install -y systemd-resolved`
    - `sudo reboot`
    - `sudo systemctl enable systemd-resolved`
	  - `sudo systemctl start systemd-resolved`
	  - `resolvectl status` (to verify)
  - Setup curl
    - Sigh.. Debian
    - `sudo apt install -y curl`

- Config
  - Verbose boot
    - This can help with boot issues, it just disables quiet boot mode
    - `sudo nano /etc/default/grub`
    - Add `GRUB_CMDLINE_LINUX_DEFAULT=""`
    - `sudo update-grub`
    - `sudo reboot`
  - Enable ethernet
    - `sudo nano /etc/systemd/network/10-eth0.network`
      ```
        [Match]
        Name=enp170s0

        [Network]
        DHCP=ipv4
      ```
    - `sudo reboot`
    - `sudo ip addr` (to verify)
  - Setup mDNS
    - `sudo nano /etc/hosts`
      - Set `127.0.1.1 bl<num>`
  - Disable wifi
    - `sudo nano /etc/network/interfaces`
    - Remove the wifi block
    - `sudo reboot`
    - `sudo networkctl` (to verify)
  - Set static dns
    - Without this, the node can’t resolve containers before dns is setup.
      - Since dns runs on k0s, a reboot creates a cycle, dns -> k0s -> dns.
    - `sudo nano /etc/systemd/resolved.conf`
      ```
        DNS=1.1.1.1
        FallbackDNS=1.1.1.1
      ```
      - Note: FallbackDNS only takes effect if DHCP doesn't provide anything. It's not a true failover.

- K0s
  - NA